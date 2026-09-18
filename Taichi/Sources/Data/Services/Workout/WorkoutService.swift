//
//  WorkoutService.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

final class WorkoutService {
    @Injected var networkService: NetworkService
    @Injected var localStorageService: LocalStorageService

    // MARK: - Home (Plan tab)

    /// The signed-up plan, the daily routines shelf, and a "Picks for today" list -- everything
    /// the Plan tab's main screen shows in one call.
    func home(limit: Int = 5) -> AnyPublisher<HomeContent, NetworkError> {
        networkService
            .get(endpoint: "/v1/plans/home", parameters: ["limit": limit], responseType: APIResponse<HomeResponseDto>.self)
            .map { Self.homeContent(from: $0.data) }
            .eraseToAnyPublisher()
    }

    // MARK: - Plans

    /// One plan with its full day-by-day schedule -- drives the 30-Day Schedule screen.
    func plan(id: String) -> AnyPublisher<WorkoutPlan, NetworkError> {
        networkService
            .get(endpoint: "/v1/plans/\(id)", parameters: nil, responseType: APIResponse<PlanResponseDto>.self)
            .map(\.data)
            .map(Self.mapPlan)
            .eraseToAnyPublisher()
    }

    // MARK: - Workout day

    /// One day (a plan day, or a Discover/daily-routine item) with its exercise list, each
    /// exercise already carrying its full instructions -- the API embeds them here, no separate
    /// per-exercise call needed. `workoutId` is the `planId#dayId` pair `WorkoutDay.id` composes.
    func workout(id workoutId: String) -> AnyPublisher<WorkoutDay, NetworkError> {
        let (planId, dayId) = Self.split(workoutId)
        let overrides = localStorageService.exerciseDurationOverrides

        return networkService
            .get(endpoint: "/v1/plans/\(planId)/days/\(dayId)", parameters: nil, responseType: APIResponse<PlanDayResponseDto>.self)
            .map { Self.mapDayDetail($0.data, overrides: overrides) }
            .eraseToAnyPublisher()
    }

    /// Marks a day started; must run once before the server accepts any `saveDayProgress` call.
    func startDay(workoutId: String) -> AnyPublisher<Void, NetworkError> {
        let (planId, dayId) = Self.split(workoutId)
        return networkService
            .put(endpoint: "/v1/plans/\(planId)/days/\(dayId)/start", body: nil, responseType: APIResponse<DayProgressResponseDto>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Records one finished exercise (or just a duration tick with no exercise) against a day.
    func saveDayProgress(workoutId: String, completedExerciseId: String?, activeDurationSeconds: Int) -> AnyPublisher<Void, NetworkError> {
        let (planId, dayId) = Self.split(workoutId)
        let body = UpdateDayProgressDto(completedExerciseId: completedExerciseId, activeDurationSeconds: activeDurationSeconds)

        return networkService
            .put(endpoint: "/v1/plans/\(planId)/days/\(dayId)/progress", body: body, responseType: APIResponse<DayProgressResponseDto>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Clears a day's server-side progress -- the "Restart" action on the Workout Day screen.
    func resetDayProgress(workoutId: String) -> AnyPublisher<Void, NetworkError> {
        let (planId, dayId) = Self.split(workoutId)
        return networkService
            .delete(endpoint: "/v1/plans/\(planId)/days/\(dayId)/progress", parameters: nil, responseType: APIResponse<DayProgressResponseDto>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    // MARK: - Daily routines

    /// One routine's fixed session list -- the "Daily Routine" screen behind a Challenge card.
    func dailyRoutine(id: String) -> AnyPublisher<DailyRoutineDetail, NetworkError> {
        networkService
            .get(endpoint: "/v1/plans/daily-routines/\(id)", parameters: nil, responseType: APIResponse<DailyRoutineResponseDto>.self)
            .map { dto in
                DailyRoutineDetail(
                    title: dto.data.title,
                    imageUrl: Self.url(dto.data.imageUrl),
                    sessionCount: dto.data.sessionCount ?? (dto.data.items ?? []).count,
                    items: (dto.data.items ?? []).map(Self.mapRoutineItem)
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Discover

    /// Grouped Discover sections, one per goal category.
    func discoverContent(sectionLimit: Int = 10) -> AnyPublisher<DiscoverContent, NetworkError> {
        networkService
            .get(endpoint: "/v1/plans/discovery", parameters: ["limit": sectionLimit], responseType: APIResponse<DiscoveryResponseDto>.self)
            .map { dto in
                DiscoverContent(
                    recent: (dto.data.recent ?? []).map(Self.mapDiscoveryItem),
                    sections: (dto.data.sections ?? []).map { section in
                        DiscoverSection(id: section.category,
                                        title: section.title,
                                        items: (section.items ?? []).map(Self.mapDiscoveryItem))
                    }
                )
            }
            .eraseToAnyPublisher()
    }

    /// Every workout in one category, paged -- the "View all" screen behind a section header.
    func categoryPage(category: String, page: Int = 1, limit: Int = 20) -> AnyPublisher<WorkoutPage, NetworkError> {
        networkService
            .get(endpoint: "/v1/plans/category/\(category)", parameters: ["page": page, "limit": limit], responseType: CategoryPageResponseDto.self)
            .map { dto in
                WorkoutPage(items: dto.data.map(Self.mapDiscoveryItem), page: dto.page, totalPages: dto.totalPages)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Splitting the composite workout id

extension WorkoutService {
    static func split(_ workoutId: String) -> (planId: String, dayId: String) {
        guard let range = workoutId.range(of: "#") else { return (workoutId, workoutId) }
        return (String(workoutId[..<range.lowerBound]), String(workoutId[range.upperBound...]))
    }
}

// MARK: - DTO -> domain

private extension WorkoutService {
    static func url(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    /// The API sends `durationSeconds` as a non-integer number (seen live as e.g. `660.016`), but
    /// the domain model and UI want whole seconds.
    static func seconds(_ raw: Double?) -> Int? {
        raw.map { Int($0.rounded()) }
    }

    static func homeContent(from dto: HomeResponseDto) -> HomeContent {
        HomeContent(
            currentPlan: dto.currentPlan.map(mapCurrentPlan),
            dailyRoutines: (dto.dailyRoutines ?? []).map(mapRoutineSummary),
            justForYou: (dto.justForYou ?? []).map(mapJustForYou)
        )
    }

    static func mapCurrentPlan(_ dto: CurrentPlanDTO) -> HomePlanSummary {
        let day = dto.currentDay
        let workoutDay = day.map {
            WorkoutDay(
                planId: dto.planId,
                dayId: $0.dayId,
                dayNumber: 0,
                stageCode: nil,
                planName: dto.title,
                title: $0.title,
                description: "",
                level: "",
                isRestDay: false,
                isPremium: false,
                imageUrl: url($0.imageUrl),
                durationSeconds: ($0.durationMinutes ?? 0) * 60,
                exerciseCount: $0.exerciseCount ?? 0,
                kcal: $0.calories,
                exercises: []
            )
        }

        return HomePlanSummary(
            planId: dto.planId,
            title: dto.title,
            status: dto.status,
            currentDay: workoutDay,
            durationText: day?.durationMinutes.map { "\($0) Min" },
            exercisesText: day?.exerciseCount.map { "\($0) Exercises" }
        )
    }

    static func mapRoutineSummary(_ dto: DailyRoutineSummaryDTO) -> DailyRoutineSummary {
        DailyRoutineSummary(id: dto.routineId, title: dto.title, imageUrl: url(dto.imageUrl), sessionCount: dto.sessionCount ?? 0)
    }

    static func mapJustForYou(_ dto: JustForYouItemDTO) -> WorkoutDay {
        WorkoutDay(
            planId: dto.planId,
            dayId: dto.dayId,
            dayNumber: 0,
            stageCode: nil,
            planName: "",
            title: dto.title,
            description: "",
            level: dto.difficulty ?? "",
            isRestDay: false,
            isPremium: dto.isPremium ?? false,
            imageUrl: url(dto.imageUrl),
            durationSeconds: (dto.durationMinutes ?? 0) * 60,
            exerciseCount: dto.exerciseCount ?? 0,
            kcal: nil,
            exercises: []
        )
    }

    static func mapRoutineItem(_ dto: DailyRoutineWorkoutDTO) -> WorkoutDay {
        WorkoutDay(
            planId: dto.planId,
            dayId: dto.dayId,
            dayNumber: 0,
            stageCode: nil,
            planName: "",
            title: dto.title,
            description: "",
            level: dto.difficulty ?? "",
            isRestDay: false,
            isPremium: dto.isPremium ?? false,
            imageUrl: url(dto.imageUrl),
            durationSeconds: (dto.durationMinutes ?? 0) * 60,
            exerciseCount: dto.exerciseCount ?? 0,
            kcal: nil,
            exercises: []
        )
    }

    static func mapDiscoveryItem(_ dto: DiscoveryItemDTO) -> WorkoutDay {
        WorkoutDay(
            planId: dto.planId,
            dayId: dto.dayId,
            dayNumber: 0,
            stageCode: nil,
            planName: "",
            title: dto.title,
            description: "",
            level: dto.difficulty ?? "",
            isRestDay: false,
            isPremium: dto.isPremium ?? false,
            imageUrl: url(dto.imageUrl),
            durationSeconds: Self.seconds(dto.durationSeconds) ?? ((dto.durationMinutes ?? 0) * 60),
            exerciseCount: dto.exerciseCount ?? 0,
            kcal: dto.calories,
            exercises: []
        )
    }

    static func mapPlan(_ dto: PlanResponseDto) -> WorkoutPlan {
        let days = (dto.days ?? []).map { mapPlanDayRow($0, planId: dto.planId, planTitle: dto.title) }

        return WorkoutPlan(
            id: dto.planId,
            title: dto.title,
            category: dto.category ?? "",
            coverImageUrl: url(days.first?.imageUrl?.absoluteString),
            totalDays: dto.totalDays,
            progressStatus: dto.progress?.status ?? "not_started",
            progressPercent: dto.progress?.progressPercent ?? 0,
            currentDayId: dto.progress?.currentDayId,
            phases: phases(for: days, declared: dto.stages, planTitle: dto.title)
        )
    }

    /// The API returns a flat day list; the Schedule screen renders stage sections. Days are
    /// grouped on `stageCode` when the plan declares stages, and otherwise collapse into a single
    /// section named after the plan.
    static func phases(for days: [WorkoutDay], declared: [PlanStageDTO]?, planTitle: String) -> [WorkoutPhase] {
        let grouped = Dictionary(grouping: days) { $0.stageCode }
        let codes = grouped.keys.compactMap { $0 }.sorted()

        guard !codes.isEmpty else {
            return days.isEmpty ? [] : [WorkoutPhase(id: "all", number: nil, name: planTitle, days: days)]
        }

        return codes.map { code in
            let name = declared?.first { $0.stageCode == code }?.title ?? ""
            return WorkoutPhase(id: "stage-\(code)", number: code, name: name, days: grouped[code] ?? [])
        }
    }

    static func mapPlanDayRow(_ dto: PlanDayRowDTO, planId: String, planTitle: String) -> WorkoutDay {
        WorkoutDay(
            planId: planId,
            dayId: dto.dayId,
            dayNumber: dto.dayIndex ?? 0,
            stageCode: dto.stageCode,
            planName: planTitle,
            title: dto.title,
            description: "",
            level: dto.difficulty ?? "",
            isRestDay: false,
            isPremium: dto.isPremium ?? false,
            imageUrl: url(dto.imageUrl),
            durationSeconds: Self.seconds(dto.durationSeconds) ?? ((dto.durationMinutes ?? 0) * 60),
            exerciseCount: dto.exerciseCount ?? 0,
            kcal: dto.calories,
            exercises: []
        )
    }

    static func mapDayDetail(_ dto: PlanDayResponseDto, overrides: [String: Int]) -> WorkoutDay {
        let image = url(dto.imageUrl)
        let exercises = (dto.exercises ?? [])
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { mapExercise($0, overrides: overrides) }

        return WorkoutDay(
            planId: dto.planId,
            dayId: dto.dayId,
            dayNumber: dto.dayIndex ?? 0,
            stageCode: nil,
            planName: dto.title,
            title: dto.title,
            description: (dto.description ?? []).joined(separator: " "),
            level: dto.difficulty ?? "",
            isRestDay: false,
            isPremium: dto.isPremium ?? false,
            imageUrl: image,
            durationSeconds: Self.seconds(dto.durationSeconds) ?? ((dto.durationMinutes ?? 0) * 60),
            exerciseCount: dto.exercises?.count ?? 0,
            kcal: dto.calories,
            exercises: exercises
        )
    }

    /// Exercises have no rest interval in this API -- each one already carries the pace the plan
    /// wants, so the session player runs straight through to the next exercise.
    static func mapExercise(_ dto: PlanDayExerciseDTO, overrides: [String: Int]) -> WorkoutExercise {
        let movement = dto.movement
        let id = dto.exerciseId

        return WorkoutExercise(
            id: id,
            order: dto.orderIndex,
            name: movement?.nameEn ?? movement?.eventName ?? "",
            imageUrl: url(movement?.imageUrl),
            videoUrl: url(movement?.videoUrl),
            // A saved edit wins over the server's figure, so the Day list, the detail screen and
            // the net-duration total all agree on what the user chose.
            durationSeconds: overrides[id] ?? Self.seconds(dto.durationSeconds) ?? 0,
            howTo: movement?.instructionList ?? [],
            commonMistakes: movement?.commonMistakes ?? [],
            breathingTips: movement?.breathingTips ?? [],
            guidance: movement?.guidance ?? ""
        )
    }
}

// MARK: - Home domain

struct HomeContent {
    let currentPlan: HomePlanSummary?
    let dailyRoutines: [DailyRoutineSummary]
    let justForYou: [WorkoutDay]

    static let empty = HomeContent(currentPlan: nil, dailyRoutines: [], justForYou: [])
}

struct HomePlanSummary {
    let planId: String
    let title: String
    /// `not_started` / `in_progress` / `completed`.
    let status: String
    /// Empty for a plan the API returns with no next day (shouldn't normally happen).
    let currentDay: WorkoutDay?
    let durationText: String?
    let exercisesText: String?

    var buttonTitle: String { status == "not_started" ? "Start now" : "Continue" }
}

struct DailyRoutineSummary: Identifiable {
    let id: String
    let title: String
    let imageUrl: URL?
    let sessionCount: Int

    var subtitleLabel: String { "\(sessionCount) Sessions" }
}

// MARK: - Discover domain

/// One daily routine: its cover photo and session list, for the `01/ Daily Routine` screen.
struct DailyRoutineDetail {
    let title: String
    let imageUrl: URL?
    let sessionCount: Int
    let items: [WorkoutDay]
}

/// Everything the Discover tab shows: the workouts practised most recently (the untitled photo
/// carousel), then the four goal sections.
struct DiscoverContent {
    let recent: [WorkoutDay]
    let sections: [DiscoverSection]
}

struct DiscoverSection: Identifiable {
    /// The plan goal category, e.g. `BALANCE_MOBILITY` -- also what `/v1/plans/category/{id}` takes.
    let id: String
    let title: String
    let items: [WorkoutDay]
}

/// One page of a category's listing.
struct WorkoutPage {
    let items: [WorkoutDay]
    let page: Int
    let totalPages: Int
}

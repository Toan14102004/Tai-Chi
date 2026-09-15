//
//  ProgressService.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Reads and writes the Progress tab's data. Every call needs a registered deviceId --
//  see DeviceRegistrationService -- which the tab's view models register before their first load.
//

import Combine
import Foundation

final class ProgressService {
    @Injected var networkService: NetworkService
    @Injected var deviceRegistration: DeviceRegistrationService

    private var deviceId: String { deviceRegistration.deviceId }

    func registerDeviceIfNeeded() -> AnyPublisher<Void, NetworkError> {
        deviceRegistration.registerIfNeeded()
    }

    // MARK: - GET /v1/users/progress

    /// Bundles the weekly chart, the streak calendar and the "Exercises" card in one call --
    /// see the header comment on ProgressAPIModels.swift for why this replaced three separate
    /// (now-404) endpoints.
    private func progress(from: Date, to: Date) -> AnyPublisher<UserProgressResponseDto, NetworkError> {
        networkService
            .get(endpoint: "/v1/users/progress",
                 parameters: ["from": Self.dayFormatter.string(from: from),
                             "to": Self.dayFormatter.string(from: to),
                             "timezoneOffsetMinutes": Self.timezoneOffsetMinutes],
                 responseType: APIResponse<UserProgressResponseDto>.self)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    /// One bar of the weekly chart, or the ring for a single selected day.
    func dailyTotals(from: Date, to: Date) -> AnyPublisher<[ProgressDay], NetworkError> {
        progress(from: from, to: to)
            .map { dto in
                let byDay = Dictionary(uniqueKeysWithValues: (dto.range?.days ?? []).map { ($0.date, $0) })
                return Self.eachDay(from: from, to: to).map { day in
                    let key = Self.dayFormatter.string(from: day)
                    let row = byDay[key]
                    return ProgressDay(date: day, calories: row?.calories ?? 0, durationMinutes: row?.durationMinutes ?? 0)
                }
            }
            .eraseToAnyPublisher()
    }

    /// Consecutive active days ending on `date`, computed over whatever window the caller already
    /// fetched -- a real count from real entries, capped at the window length rather than however
    /// far back the streak might actually go. `/v1/users/progress` also returns its own
    /// `streak.currentDays`, but that's unverified against a live device so this stays the
    /// source of truth until it's checked.
    func streakDays(endingOn date: Date, in days: [ProgressDay]) -> Int {
        let active = Set(days.filter { $0.calories > 0 || $0.durationMinutes > 0 }.map { Self.dayFormatter.string(from: $0.date) })
        var streak = 0
        var cursor = date
        while active.contains(Self.dayFormatter.string(from: cursor)) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    // MARK: - Activities (manual log -- backend removed, see below)

    /// `GET /activities` this used to read is gone (404 as of 2026-09-14, see the header comment
    /// on ProgressAPIModels.swift) and `/v1/users/progress` has nothing to replace it with: it
    /// only reports Tai Chi workout attempts, not free-form logged activities. Returns empty so
    /// the Home screen's load doesn't fail outright, but the "Activities" list and its edit
    /// screen have no live data source right now -- needs a product call on what to do with that
    /// entry point until the backend adds one back.
    func activities(on date: Date) -> AnyPublisher<[ProgressActivity], NetworkError> {
        Just([]).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }

    /// `POST /activities` -- retired along with `GET /activities` (see `activities(on:)`), so this
    /// call will 404. Left in place rather than deleted since removing the "Add Activity" feature
    /// is a product decision, not a client bug fix.
    func createActivity(category: ProgressCategory,
                        activityAt: Date,
                        durationSeconds: Int,
                        calories: Double) -> AnyPublisher<Void, NetworkError>
    {
        let body = CreateActivityRequest(
            deviceId: deviceId,
            categoryId: category.id,
            activityAt: Self.isoFormatter.string(from: activityAt),
            timezoneOffsetMinutes: Self.timezoneOffsetMinutes,
            durationSeconds: durationSeconds,
            caloriesMode: "custom",
            calories: calories
        )
        return networkService
            .post(endpoint: "/activities", body: body, responseType: APIResponse<EmptyDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func updateActivity(id: String, durationSeconds: Int, calories: Double) -> AnyPublisher<Void, NetworkError> {
        let body = UpdateActivityRequest(deviceId: deviceId, durationSeconds: durationSeconds, caloriesMode: "custom", calories: calories)
        return networkService
            .patch(endpoint: "/activities/\(id)", body: body, responseType: APIResponse<EmptyDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func deleteActivity(id: String) -> AnyPublisher<Void, NetworkError> {
        // `NetworkService.delete(parameters:)` encodes `parameters` as a JSON body on any
        // non-GET method, but this endpoint reads `deviceId` from the query string only -- a
        // body-only deviceId gets "deviceId must be a string" back. Put it on the URL instead.
        let encodedDeviceId = deviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? deviceId
        return networkService
            .delete(endpoint: "/activities/\(id)?deviceId=\(encodedDeviceId)", responseType: APIResponse<EmptyDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    // MARK: - Categories

    /// `GET /activity-categories` -- also retired (404); see `activities(on:)`.
    func categories() -> AnyPublisher<[ProgressCategory], NetworkError> {
        networkService
            .get(endpoint: "/activity-categories", parameters: nil, responseType: APIResponse<[ActivityCategoryDTO]>.self)
            .map { dto in
                dto.data
                    .map(Self.mapCategory)
                    .sorted { lhs, rhs in
                        if lhs.popular != rhs.popular { return lhs.popular && !rhs.popular }
                        return lhs.name < rhs.name
                    }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Participated workouts

    /// The Progress tab's "Exercises" card -- what `WorkoutProgressStore.markWorkoutCompleted`
    /// pushes to the server ends up here. `GET /users/{deviceId}/workouts/participated` this used
    /// to read is gone (404); `/v1/users/progress`'s per-day `activities` list is the replacement.
    func participatedWorkouts(on date: Date) -> AnyPublisher<[ParticipatedWorkout], NetworkError> {
        let key = Self.dayFormatter.string(from: date)
        return progress(from: date, to: date)
            .map { dto in
                let day = (dto.range?.days ?? []).first { $0.date == key }
                return (day?.activities ?? []).map(Self.mapParticipated)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Dates

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    private static let isoFormatter = ISO8601DateFormatter()

    private static var timezoneOffsetMinutes: Int { TimeZone.current.secondsFromGMT() / 60 }

    private static func eachDay(from: Date, to: Date) -> [Date] {
        var days: [Date] = []
        var cursor = Calendar.current.startOfDay(for: from)
        let end = Calendar.current.startOfDay(for: to)
        while cursor <= end {
            days.append(cursor)
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return days
    }

    // MARK: - DTO -> domain

    private static func mapCategory(_ dto: ActivityCategoryDTO) -> ProgressCategory {
        ProgressCategory(id: dto.id, name: dto.name, iconKey: dto.iconKey, met: dto.met ?? 4, popular: dto.popular ?? false)
    }

    /// `id` recomposes the `planId#dayId` pair `WorkoutDay.id`/`WorkoutService.split(_:)` use, so
    /// tapping this card can push straight into `workoutDay(workoutId:)`.
    private static func mapParticipated(_ dto: ProgressRangeActivityDTO) -> ParticipatedWorkout {
        let isCompleted = dto.status == "completed"
        let date = (dto.startedAt).flatMap(isoFormatter.date)

        return ParticipatedWorkout(
            id: "\(dto.planId ?? "")#\(dto.dayId ?? "")",
            name: dto.title ?? dto.planTitle ?? "",
            imageUrl: dto.imageUrl.flatMap(URL.init),
            level: "",
            dayNumber: dto.dayIndex,
            isCompleted: isCompleted,
            progressFraction: isCompleted ? 1 : (dto.progressPercent ?? 0) / 100,
            durationSeconds: dto.durationSeconds ?? 0,
            calories: dto.calories ?? 0,
            date: date
        )
    }
}

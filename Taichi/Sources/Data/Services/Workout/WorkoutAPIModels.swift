//
//  WorkoutAPIModels.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//
//  Wire format for https://tai-chi.limgrow.com (see /api-docs-json). These stay a thin mirror of
//  the JSON -- the mapping into the domain models the UI uses lives in WorkoutService, so a field
//  rename on the server touches one layer only.
//
//  Every endpoint here needs a registered user: `deviceId` travels as a header (AuthInterceptor),
//  set once via DeviceRegistrationService.register(answers:) at the end of Profile Setup.
//

import Foundation

// MARK: - Envelope

/// Every `/v1/*` endpoint wraps its payload as `{ "success": true, "data": ... }`.
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}

/// Decodes a `{success, data}` response whose `data` payload carries nothing the caller needs.
struct EmptyDTO: Codable {}

// MARK: - GET /v1/plans/home

struct HomeResponseDto: Codable {
    /// Exactly three personalized plans. Replaced the single `currentPlan` this endpoint used to
    /// return -- reading that field now always yields nothing, which hid the "Your Plan" section.
    let yourPlans: [CurrentPlanDTO]?
    let dailyRoutines: [DailyRoutineSummaryDTO]?
    let justForYou: [JustForYouItemDTO]?
}

struct CurrentPlanDTO: Codable {
    let title: String
    let status: String
    let action: String
    let planId: String
    let category: String?
    let totalDays: Int?
    let currentDay: CurrentDayDTO?
}

struct CurrentDayDTO: Codable {
    let dayId: String
    let title: String
    let imageUrl: String?
    let durationMinutes: Int?
    let calories: Double?
    let videoUrl: String?
    let exerciseCount: Int?
    let completedExerciseCount: Int?
    let progressPercent: Double?
}

struct DailyRoutineSummaryDTO: Codable {
    let routineId: String
    let title: String
    let imageUrl: String?
    let sessionCount: Int?
}

struct JustForYouItemDTO: Codable {
    let planId: String
    let dayId: String
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let difficulty: String?
    let durationMinutes: Int?
    let exerciseCount: Int?
    let isPremium: Bool?
}

// MARK: - GET /v1/plans/daily-routines[/{routineId}]

struct DailyRoutineResponseDto: Codable {
    let routineId: String
    let title: String
    let imageUrl: String?
    let sessionCount: Int?
    let items: [DailyRoutineWorkoutDTO]?
}

struct DailyRoutineWorkoutDTO: Codable {
    let planId: String
    let dayId: String
    let title: String
    let imageUrl: String?
    let difficulty: String?
    let durationMinutes: Int?
    let exerciseCount: Int?
    let isPremium: Bool?
}

// MARK: - GET /v1/plans/discovery, /v1/plans/category/{category}

struct DiscoveryResponseDto: Codable {
    /// Recently practised workout days (`RecentWorkoutResponseDto`) -- the same row fields as a
    /// section item plus `lastPracticedAt`/`status`/`action`, which nothing reads yet.
    let recent: [DiscoveryItemDTO]?
    let sections: [DiscoverySectionDTO]?
}

struct DiscoverySectionDTO: Codable {
    let category: String
    let title: String
    let totalPlans: Int?
    let items: [DiscoveryItemDTO]?
}

/// One workout row shared by `/v1/plans/discovery`, `/v1/plans/category/{category}` and
/// `/v1/plans/daily-routines/{routineId}`'s items.
struct DiscoveryItemDTO: Codable {
    let planId: String
    let dayId: String
    let title: String
    let imageUrl: String?
    let difficulty: String?
    // Seen live as a non-integer (e.g. 660.016) -- Double, not Int; see WorkoutService.seconds(_:).
    let durationSeconds: Double?
    let durationMinutes: Int?
    let exerciseCount: Int?
    let calories: Double?
    let isPremium: Bool?
    let category: String?
}

/// `GET /v1/plans/category/{category}` replies with page/limit/total/totalPages at the top level,
/// not nested under `data` the way every other list endpoint does.
struct CategoryPageResponseDto: Codable {
    let success: Bool
    let data: [DiscoveryItemDTO]
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

// MARK: - GET /v1/plans/{planId}

struct PlanResponseDto: Codable {
    let planId: String
    let title: String
    let category: String?
    let totalDays: Int
    let stages: [PlanStageDTO]?
    let progress: PlanProgressDTO?
    let days: [PlanDayRowDTO]?
}

struct PlanStageDTO: Codable {
    let stageCode: Int
    let title: String
    let dayCount: Int?
}

struct PlanProgressDTO: Codable {
    let status: String?
    let completedDayCount: Int?
    let totalDays: Int?
    let progressPercent: Double?
    let currentDayId: String?
    let action: String?
}

struct PlanDayRowDTO: Codable {
    let dayId: String
    let dayIndex: Int?
    let stageCode: Int?
    let workoutId: String?
    let title: String
    let imageUrl: String?
    let durationSeconds: Double?
    let durationMinutes: Int?
    let calories: Double?
    let difficulty: String?
    let exerciseCount: Int?
    let completedExerciseCount: Int?
    let progressPercent: Double?
    let status: String?
    let isPremium: Bool?
}

// MARK: - GET /v1/plans/{planId}/days/{dayId}

struct PlanDayResponseDto: Codable {
    let planId: String
    let dayId: String
    let dayIndex: Int?
    let category: String?
    let title: String
    let imageUrl: String?
    let description: [String]?
    let durationSeconds: Double?
    let durationMinutes: Int?
    let calories: Double?
    let difficulty: String?
    let isPremium: Bool?
    let exercises: [PlanDayExerciseDTO]?
    let progress: DayProgressResponseDto?
}

struct PlanDayExerciseDTO: Codable {
    let exerciseId: String
    let orderIndex: Int
    let durationSeconds: Double?
    let movement: MovementDTO?
}

struct MovementDTO: Codable {
    let movementId: String
    let nameEn: String?
    let eventName: String?
    let imageUrl: String?
    let videoUrl: String?
    let instructionList: [String]?
    let commonMistakes: [String]?
    let breathingTips: [String]?
    let guidance: String?
    let calorie: Double?
}

// MARK: - PUT /v1/plans/{planId}/days/{dayId}/start, /progress; DELETE .../progress

struct UpdateDayProgressDto: Codable {
    let completedExerciseId: String?
    let activeDurationSeconds: Int
}

struct DayProgressResponseDto: Codable {
    let status: String?
    // Cumulative active seconds -- same non-integer risk as DiscoveryItemDTO.durationSeconds.
    let activeDurationSeconds: Double?
    let completedExerciseIds: [String]?
    let completedCount: Int?
    let totalExercises: Int?
    let progressPercent: Double?
}

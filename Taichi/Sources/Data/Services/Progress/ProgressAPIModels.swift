//
//  ProgressAPIModels.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//
//  `/activities`, `/activity-categories` and `/users/{deviceId}/workouts/participated` (the
//  types below this comment) were verified live on 2026-08-26 but are GONE as of 2026-09-14 --
//  all three now 404. The backend replaced them with one bundled `GET /v1/users/progress`
//  (`from`/`to`/`timezoneOffsetMinutes` query, see `UserProgressResponseDto` below), which
//  ProgressService now reads for the weekly chart, streak and "Exercises" card. That endpoint
//  has no equivalent for a free-form logged activity (no categories, no create/update/delete) --
//  only Tai Chi workout attempts -- so the manual "Add Activity" flow these old types back has
//  no live backend right now; see ProgressService for how that's handled meanwhile.
//

import Foundation

// MARK: - GET /v1/users/progress

/// Mirrors `UserProgressResponseDto` from `/api-docs-json`.
struct UserProgressResponseDto: Codable {
    let overview: ProgressOverviewDTO?
    let streak: ProgressStreakDTO?
    let range: ProgressRangeDTO?
}

struct ProgressOverviewDTO: Codable {
    let workoutCount: Int?
    let durationSeconds: Int?
    let calories: Double?
}

struct ProgressStreakDTO: Codable {
    let currentDays: Int?
    let activeDates: [String]?
}

struct ProgressRangeDTO: Codable {
    let days: [ProgressRangeDayDTO]?
}

struct ProgressRangeDayDTO: Codable {
    let date: String
    /// The server reports a fractional minute count (e.g. `2.3`), not a whole one -- declaring
    /// this `Int` blew up decoding the entire date range the first time a day landed on a
    /// non-whole value.
    let durationMinutes: Double?
    let calories: Double?
    let activities: [ProgressRangeActivityDTO]?
}

/// One workout attempt inside a range day -- the only kind of "activity" this endpoint knows
/// about (`durationSource`/`caloriesSource` show it's always derived from a plan day, never a
/// free-form log entry).
struct ProgressRangeActivityDTO: Codable {
    /// Declared optional like every other field here, unlike the OpenAPI doc's "required" --
    /// it's never read (`mapParticipated` composes `ParticipatedWorkout.id` from `planId`/`dayId`
    /// instead), so it must never be the one field that takes down decoding the whole day range
    /// if a future/edge-case activity row omits it.
    let activityId: String?
    let planId: String?
    let dayId: String?
    let dayIndex: Int?
    let planTitle: String?
    let title: String?
    let imageUrl: String?
    let status: String?
    let progressPercent: Double?
    let durationSeconds: Int?
    let calories: Double?
    let activityDate: String?
    let startedAt: String?
    let completedAt: String?
}

// MARK: - Activities (legacy -- endpoints below now 404, see header comment)

struct CreateActivityRequest: Codable {
    let deviceId: String
    let categoryId: String
    let activityAt: String
    let timezoneOffsetMinutes: Int
    let durationSeconds: Int
    let caloriesMode: String
    let calories: Double
}

struct UpdateActivityRequest: Codable {
    let deviceId: String
    let durationSeconds: Int?
    let caloriesMode: String?
    let calories: Double?
}

// MARK: - Categories

struct ActivityCategoryDTO: Codable, Identifiable {
    let id: String
    let name: String
    let iconKey: String?
    let met: Double?
    let popular: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, iconKey, met, popular
    }
}

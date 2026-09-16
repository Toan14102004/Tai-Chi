//
//  LocalStorageService.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

protocol UserDefaultService: AnyObject {
    // App flags
    var isFirstTimeOpenApp: Bool { get set }
    var isFirstTimeUsingApp: Bool { get set }
    
    // Subscription
    var weeklyFreeTrialEnabled: Bool { get set }
    var monthlyFreeTrialEnabled: Bool { get set }
    var yearlyFreeTrialEnabled: Bool { get set }
    
    // Global Ad Config
    var isDisplayPremiumAfterSplash: Bool { get set }
    var isDisplayLanguageAfterSplash: Bool { get set }
    var distanceCountShowInterShare: Int { get set }
    var distanceTimeShowOtherAds: Int { get set }
    var distanceTimeShowSameAds: Int { get set }
    
    // Taichi - Inter
    var foodInterSplash: AdPlacement { get set }
    var foodInterSplashHight: AdPlacement { get set }
    var foodInterShare: AdPlacement { get set }
    var foodInterShareHight: AdPlacement { get set }
    
    // Taichi - Native
    var foodNativeLanguage: AdPlacement { get set }
    var foodNativeLanguageClick: AdPlacement { get set }
    var foodNativeLanguageClickHight: AdPlacement { get set }
    var foodNativeLanguageHight: AdPlacement { get set }
    var profileSetupCompactAd: AdPlacement { get set }
    var profileSetupMediumAd: AdPlacement { get set }
    var practiceCompactAd: AdPlacement { get set }
    var discoverCompactAd: AdPlacement { get set }
    /// The second native ad the Discover feed's design inserts further down, after the first two
    /// category sections -- a distinct key so it loads its own `NativeAd` instead of reusing
    /// `discoverCompactAd`'s (one `NativeAd` can't back two ad views on screen at once).
    var discoverCompactSecondaryAd: AdPlacement { get set }
    var profileMediumAd: AdPlacement { get set }

    // Taichi - Rewarded
    var discoverUnlockRewardedAd: AdPlacement { get set }

    // Taichi - Limit
    // var countIdentityScan: Int { get set }
    var maxFreeIdentityScan: Int { get set }

    // Profile Setup
    var profileSetupAnswers: ProfileSetupAnswers { get set }

    /// Stable per-install identity, sent as the `deviceId` header on every /v1 call.
    var deviceId: String { get }
    var isDeviceRegistered: Bool { get set }

    // Practice / Workout progress
    var workoutSettings: WorkoutSettings { get set }
    var completedExerciseIds: [String: [String]] { get set }
    var completedWorkoutIds: [String] { get set }
    var currentWorkoutDayId: String? { get set }
    var currentProgramId: String? { get set }
    var exerciseDurationOverrides: [String: Int] { get set }
    var workoutCompletedCounts: [String: Int] { get set }
    var unlockedWorkoutIds: [String] { get set }

    // Profile
    var userProfile: UserProfile { get set }
    var workoutReminders: [WorkoutReminder] { get set }
    var hasSeededReminders: Bool { get set }
}

private enum Keys {
    // App flags
    static let isFirstTimeOpenApp = "isFirstTimeOpenApp"
    static let isFirstTimeUsingApp = "isFirstTimeUsingApp"
    
    // Subscription
    static let monthlyFreeTrialEnabled = "monthly_free_trial_enabled"
    static let weeklyFreeTrialEnabled = "weekly_free_trial_enabled"
    static let yearlyFreeTrialEnabled = "yearly_free_trial_enabled"
    
    // Global Ad Config
    static let isDisplayPremiumAfterSplash = "isDisplayPremiumAfterSplash"
    static let isDisplayLanguageAfterSplash = "is_display_language_after_splash"
    static let distanceCountShowInterShare = "distance_count_show_inter_share"
    static let distanceTimeShowOtherAds = "distance_time_show_other_ads"
    static let distanceTimeShowSameAds = "distance_time_show_same_ads"
    
    // Taichi - Inter
    static let foodInterSplash = "food_inter_splash"
    static let foodInterSplashHight = "food_inter_splash_high"
    static let foodInterShare = "food_inter_share"
    static let foodInterShareHight = "food_inter_share_high"
    
    // Taichi - Native
    static let foodNativeLanguage = "food_native_language"
    static let foodNativeLanguageHight = "food_native_language_high"
    static let foodNativeLanguageClick = "food_native_language_click"
    static let foodNativeLanguageClickHight = "food_native_language_click_high"
    static let profileSetupCompactAd = "profile_setup_compact_ad"
    static let profileSetupMediumAd = "profile_setup_medium_ad"
    static let practiceCompactAd = "practice_compact_ad"
    static let discoverCompactAd = "discover_compact_ad"
    static let discoverCompactSecondaryAd = "discover_compact_secondary_ad"
    static let profileMediumAd = "profile_medium_ad"

    // Taichi - Limit
    static let maxFreeIdentityScan = "max_free_identity_scan"

    // Profile Setup
    static let profileSetupAnswers = "profile_setup_answers"

    // Device registration
    static let deviceId = "device_id"
    static let isDeviceRegistered = "taichi_user_registered"

    // Practice / Workout progress
    static let workoutSettings = "workout_settings"
    static let completedExerciseIds = "completed_workout_exercise_ids"
    static let completedWorkoutIds = "completed_workout_ids"
    static let currentWorkoutDayId = "current_workout_day_id"
    static let currentProgramId = "current_program_id"
    static let exerciseDurationOverrides = "exercise_duration_overrides"
    static let workoutCompletedCounts = "workout_completed_counts"
    static let unlockedWorkoutIds = "unlocked_workout_ids"

    // Taichi - Rewarded
    static let discoverUnlockRewardedAd = "discover_unlock_rewarded_ad"

    // Profile
    static let userProfile = "user_profile"
    static let workoutReminders = "workout_reminders"
    static let hasSeededReminders = "has_seeded_reminders"
}

class LocalStorageService: UserDefaultService {
    static let shared = LocalStorageService()
    
    @ObjectUserDefaultWrapper(key: Keys.isFirstTimeOpenApp, defaultValue: true)
    var isFirstTimeOpenApp: Bool
    
    @ObjectUserDefaultWrapper(key: Keys.isFirstTimeUsingApp, defaultValue: true)
    var isFirstTimeUsingApp: Bool
    
    // MARK: - Subscription
    @UserDefaultWrapper(key: Keys.weeklyFreeTrialEnabled, defaultValue: true)
    var weeklyFreeTrialEnabled: Bool
    
    @UserDefaultWrapper(key: Keys.monthlyFreeTrialEnabled, defaultValue: false)
    var monthlyFreeTrialEnabled: Bool
    
    @UserDefaultWrapper(key: Keys.yearlyFreeTrialEnabled, defaultValue: false)
    var yearlyFreeTrialEnabled: Bool
    
    // MARK: Global Ad config
    @ObjectUserDefaultWrapper(key: Keys.isDisplayPremiumAfterSplash, defaultValue: true)
    var isDisplayPremiumAfterSplash: Bool
    
    @UserDefaultWrapper(key: Keys.isDisplayLanguageAfterSplash, defaultValue: true)
    var isDisplayLanguageAfterSplash: Bool
    
    @UserDefaultWrapper(key: Keys.distanceCountShowInterShare, defaultValue: 3)
    var distanceCountShowInterShare: Int
    
    @UserDefaultWrapper(key: Keys.distanceTimeShowOtherAds, defaultValue: 20)
    var distanceTimeShowOtherAds: Int
    
    @UserDefaultWrapper(key: Keys.distanceTimeShowSameAds, defaultValue: 20)
    var distanceTimeShowSameAds: Int
    
    
    // MARK: - Taichi Ad Placements
    
    // Inter
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterSplash,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterSplash: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterSplashHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterSplashHight: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterShare,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterShare: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterShareHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterShareHight: AdPlacement
    
    // Inter
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguage,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguage: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageHight: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageClick,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageClick: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageClickHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageClickHight: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.profileSetupCompactAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var profileSetupCompactAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.profileSetupMediumAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var profileSetupMediumAd: AdPlacement

    @ObjectUserDefaultWrapper(
key: Keys.practiceCompactAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var practiceCompactAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.discoverCompactAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var discoverCompactAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.discoverCompactSecondaryAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var discoverCompactSecondaryAd: AdPlacement

    // MARK: - Taichi Rewarded

    /// Rewards a Discover workout unlock. Default is Google's public rewarded test unit.
    @ObjectUserDefaultWrapper(
        key: Keys.discoverUnlockRewardedAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1712485313", isEnabled: true)
    )
    var discoverUnlockRewardedAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.profileMediumAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var profileMediumAd: AdPlacement

    // MARK: - Taichi Limit
    @UserDefaultWrapper(key: Keys.maxFreeIdentityScan, defaultValue: 3)
    var maxFreeIdentityScan: Int

    // MARK: - Profile Setup
    @ObjectUserDefaultWrapper(key: Keys.profileSetupAnswers, defaultValue: ProfileSetupAnswers())
    var profileSetupAnswers: ProfileSetupAnswers

// MARK: - Device identity
    /// Backing storage for `deviceId`. `ObjectUserDefaultWrapper`'s `defaultValue` is only ever
    /// *returned* on a cache miss, never written -- if `deviceId` used it directly with a fresh
    /// `UUID()`, every relaunch before the first explicit write would mint a new, different id,
    /// so a device registered on launch N would look unregistered (and be silently rejected by
    /// every `/activities/*` and `/workouts/{id}/progress` call) on launch N+1. `deviceId` below
    /// generates one UUID and immediately writes it back, so the miss only ever happens once.
    @ObjectUserDefaultWrapper(key: Keys.deviceId, defaultValue: String?.none)
    private var storedDeviceId: String?

    var deviceId: String {
        if let storedDeviceId { return storedDeviceId }
        let generated = UUID().uuidString
        storedDeviceId = generated
        return generated
    }

    @UserDefaultWrapper(key: Keys.isDeviceRegistered, defaultValue: false)
    var isDeviceRegistered: Bool

    // MARK: - Practice / Workout progress
    @ObjectUserDefaultWrapper(key: Keys.workoutSettings, defaultValue: WorkoutSettings())
    var workoutSettings: WorkoutSettings

    /// Finished exercises, keyed by workoutId. Scoped rather than flat because the API reuses one
    /// `exerciseId` across many workouts -- a flat list marked an exercise done everywhere it
    /// appeared as soon as it was done once. Stored under a new key for that reason: the old flat
    /// list cannot be attributed to a workout after the fact.
    @ObjectUserDefaultWrapper(key: Keys.completedExerciseIds, defaultValue: [:])
    var completedExerciseIds: [String: [String]]

    @ObjectUserDefaultWrapper(key: Keys.completedWorkoutIds, defaultValue: [])
    var completedWorkoutIds: [String]

    @ObjectUserDefaultWrapper(key: Keys.currentWorkoutDayId, defaultValue: nil)
    var currentWorkoutDayId: String?

    @ObjectUserDefaultWrapper(key: Keys.currentProgramId, defaultValue: nil)
    var currentProgramId: String?

    /// Per-exercise duration edits, keyed by exerciseId. The API has no endpoint that accepts a
    /// duration override, so these stay on the device.
    @ObjectUserDefaultWrapper(key: Keys.exerciseDurationOverrides, defaultValue: [:])
    var exerciseDurationOverrides: [String: Int]

    /// How many exercises of each workout are done, keyed by workoutId. The schedule shows a
    /// per-day percentage but only receives day summaries -- without exercise lists -- so the count
    /// has to be recorded as the session runs.
    @ObjectUserDefaultWrapper(key: Keys.workoutCompletedCounts, defaultValue: [:])
    var workoutCompletedCounts: [String: Int]

    /// Discover workouts the user has paid for with a rewarded ad. Subscribers bypass this list
    /// entirely -- see `WorkoutUnlockStore` -- so it only ever grows for free users.
    @ObjectUserDefaultWrapper(key: Keys.unlockedWorkoutIds, defaultValue: [])
    var unlockedWorkoutIds: [String]
    // MARK: - Profile
    @ObjectUserDefaultWrapper(key: Keys.userProfile, defaultValue: UserProfile())
    var userProfile: UserProfile

    @ObjectUserDefaultWrapper(key: Keys.workoutReminders, defaultValue: [])
    var workoutReminders: [WorkoutReminder]

    @UserDefaultWrapper(key: Keys.hasSeededReminders, defaultValue: false)
    var hasSeededReminders: Bool
}

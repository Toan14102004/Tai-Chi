//
//  ProfileSetupStep.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import Foundation

struct ProfileSetupOption: Hashable {
    /// What the API expects, e.g. `stiff_or_achy`.
    let value: String
    let label: String
}

/// Order, values and ranges follow `GET /v1/users/onboarding/options`, which `POST /v1/users`
/// validates against. Gender has no screen in the design, but the API requires it and serves
/// plans per gender.
enum ProfileSetupStep: Int, CaseIterable {
    case bodyConditions
    case mainGoal
    case postExerciseFeeling
    case weightStability
    case taiChiExperience
    case taiChiIntensity
    case sensitiveAreas
    case dailyCommitment
    case energyLevel
    case height
    case weight
    case targetWeight
    case age
    case gender
    case displayName
    case activityLevel
    case generatingPlan

    /// Height counts as two ticks, so there is one more tick than there are quiz steps.
    static let totalProgressSteps = 17

    var title: String {
        switch self {
        case .bodyConditions: "How does your body feel most days?"
        case .mainGoal: "What's your main goal?"
        case .postExerciseFeeling: "How does your body feel after exercise these days?"
        case .weightStability: "How stable is your weight usually?"
        case .taiChiExperience: "How experienced are you in Tai Chi?"
        case .taiChiIntensity: "Which intensity do you prefer?"
        case .sensitiveAreas: "Any areas needing extra care?"
        case .dailyCommitment: "How much time can you commit per day?"
        case .energyLevel: "How is your energy during the day?"
        case .height: "What's your height?"
        case .weight: "What's your weight?"
        case .targetWeight: "What's your target weight?"
        case .age: "What's your age?"
        case .gender: "What's your gender?"
        case .displayName: "What should we call you?"
        case .activityLevel: "What's your recent activity level?"
        case .generatingPlan: "Your Personalized Tai Chi Plan"
        }
    }

    var subtitle: String? {
        switch self {
        case .bodyConditions: "Select one or more"
        case .sensitiveAreas: "We will customize your plan to protect your body"
        case .age: "It'll help us personalize your plan to better suit your age group."
        case .generatingPlan: "We’re putting together a routine based on your goals, experience, and preferences."
        default: nil
        }
    }

    var options: [ProfileSetupOption] {
        (Self.optionPairs[self] ?? []).map { ProfileSetupOption(value: $0.0, label: $0.1) }
    }

    private static let optionPairs: [ProfileSetupStep: [(String, String)]] = [
        .bodyConditions: [
            ("stiff_or_achy", "Stiff or achy"), ("low_energy", "Low energy"), ("poor_balance", "Poor balance"),
            ("tense_or_stressed", "Tense or stressed"), ("weak_muscles", "Weak muscles"), ("feeling_okay", "Feeling okay"),
        ],
        .mainGoal: [
            ("improve_balance", "Improve balance"), ("manage_weight", "Manage weight"),
            ("build_strength", "Build strength"), ("boost_energy", "Boost energy"),
        ],
        .postExerciseFeeling: [
            ("sore_or_drained", "I feel sore or drained"), ("slower_to_recover", "I feel slower to recover"),
            ("okay_after_moving", "I feel okay after moving"), ("not_exercised_in_a_while", "I haven't exercised in a while"),
        ],
        .weightStability: [
            ("very_stable", "Very stable"), ("small_ups_and_downs", "Small ups and downs"),
            ("changes_easily", "Changes easily"), ("not_sure_or_dont_track", "Not sure / don't track"),
        ],
        .taiChiExperience: [
            ("regular", "I do it regularly"), ("tried_a_few_times", "I've only tried it a few times"),
            ("never_tried", "I've never tried it"),
        ],
        .taiChiIntensity: [
            ("gentle_and_relaxing", "Gentle & relaxing"), ("moderate_and_steady", "Moderate & steady"),
            ("active_and_challenging", "Active & challenging"), ("find_my_best_fit", "Find my best fit"),
        ],
        .sensitiveAreas: [
            ("none", "I'm all good"), ("knee", "Knee"), ("lower_back", "Lower back"), ("hip", "Hip"),
            ("shoulder", "Shoulder"), ("ankle", "Ankle"), ("wrist", "Wrist"),
        ],
        .dailyCommitment: [
            ("5_10_minutes", "5-10 minutes"), ("10_20_minutes", "10-20 minutes"),
            ("20_30_minutes", "20-30 minutes"), ("30_plus_minutes", "30+ minutes"),
        ],
        .energyLevel: [
            ("low_most_of_the_time", "Low most of the time"), ("okay_with_ups_and_downs", "Okay, with ups and downs"),
            ("generally_energetic", "Generally energetic"),
        ],
        .gender: [("female", "Female"), ("male", "Male")],
        .activityLevel: [
            ("just_starting_out", "Just starting out"), ("on_and_off", "On and off"),
            ("fairly_active", "Fairly active"), ("very_active", "Very active"),
        ],
    ]

    var singleAnswer: WritableKeyPath<ProfileSetupAnswers, String?>? {
        switch self {
        case .mainGoal: return \.mainGoal
        case .postExerciseFeeling: return \.postExerciseFeeling
        case .weightStability: return \.weightStability
        case .taiChiExperience: return \.taiChiExperience
        case .taiChiIntensity: return \.taiChiIntensity
        case .dailyCommitment: return \.dailyCommitment
        case .energyLevel: return \.energyLevel
        case .gender: return \.gender
        case .activityLevel: return \.activityLevel
        default: return nil
        }
    }

    var multiAnswer: WritableKeyPath<ProfileSetupAnswers, [String]>? {
        switch self {
        case .bodyConditions: return \.bodyConditions
        case .sensitiveAreas: return \.sensitiveAreas
        default: return nil
        }
    }

    /// The API's `exclusiveValues`: picking it clears every other selection.
    var exclusiveValue: String? {
        switch self {
        case .bodyConditions: "feeling_okay"
        case .sensitiveAreas: "none"
        default: nil
        }
    }

    var compactAdKey: AdsPreloadService.AdsPreloadKey? {
        switch self {
        case .height, .weight, .targetWeight, .generatingPlan: .profileSetupCompact
        default: nil
        }
    }

    var mediumAdKey: AdsPreloadService.AdsPreloadKey? {
        switch self {
        case .mainGoal, .postExerciseFeeling, .weightStability, .taiChiExperience, .taiChiIntensity,
             .dailyCommitment, .energyLevel, .gender, .activityLevel:
            .profileSetupMedium
        default: nil
        }
    }
}

//
//  ProfileSetupAnswers.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import Foundation

enum HeightUnit: String, Codable {
    case centimeters
    case feetInches
}

enum WeightUnit: String, Codable {
    case kilograms
    case pounds
}

/// Choice fields hold the API's option values (`ProfileSetupOption.value`), not display labels.
struct ProfileSetupAnswers: Codable, Equatable {
    var bodyConditions: [String] = []
    var mainGoal: String?
    var postExerciseFeeling: String?
    var weightStability: String?
    var taiChiExperience: String?
    var taiChiIntensity: String?
    var sensitiveAreas: [String] = []
    var dailyCommitment: String?
    var energyLevel: String?

    var heightUnit: HeightUnit = .centimeters
    var heightCm: Int?

    var weightUnit: WeightUnit = .kilograms
    var currentWeightKg: Double?
    var targetWeightKg: Double?

    var age: Int?
    var gender: String?
    var displayName: String?
    var activityLevel: String?
}

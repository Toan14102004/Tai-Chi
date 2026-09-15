//
//  DeviceRegistrationService.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Creates this install's user on the Tai Chi API. Every /v1 endpoint scoped to a user answers
//  404 USER_NOT_FOUND until `POST /v1/users` has run with the Profile Setup answers.
//

import Combine
import Foundation

final class DeviceRegistrationService {
    @Injected var networkService: NetworkService
    @Injected var localStorageService: LocalStorageService

    var deviceId: String { localStorageService.deviceId }

    var isRegistered: Bool { localStorageService.isDeviceRegistered }

    func register(answers: ProfileSetupAnswers) -> AnyPublisher<Void, NetworkError> {
        guard let onboarding = OnboardingPayload(answers: answers) else {
            return Fail(error: NetworkError.serverError(400, "Some answers are missing. Please go back and complete every step."))
                .eraseToAnyPublisher()
        }

        return networkService
            .post(endpoint: "/v1/users",
                  body: CreateUserRequest(deviceId: deviceId, onboarding: onboarding),
                  responseType: APIResponse<CreatedUserDTO>.self)
            .map { [weak self] _ in self?.localStorageService.isDeviceRegistered = true }
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    /// Registration needs the Profile Setup answers, so it only happens at the end of that flow.
    /// Anything that needs a user before then fails instead of registering an empty profile.
    func registerIfNeeded() -> AnyPublisher<Void, NetworkError> {
        guard isRegistered else {
            return Fail(error: NetworkError.serverError(404, "Finish setting up your profile first."))
                .eraseToAnyPublisher()
        }
        return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
}

private struct CreateUserRequest: Codable {
    let deviceId: String
    let onboarding: OnboardingPayload
}

/// `SubmitOnboardingDto`: every field is required.
private struct OnboardingPayload: Codable {
    let bodyConditions: [String]
    let mainGoal: String
    let postExerciseFeeling: String
    let weightStability: String
    let taiChiExperience: String
    let taiChiIntensity: String
    let sensitiveAreas: [String]
    let dailyCommitment: String
    let energyLevel: String
    let heightCm: Int
    let weightKg: Double
    let targetWeightKg: Double
    let age: Int
    let gender: String
    let displayName: String
    let activityLevel: String

    init?(answers: ProfileSetupAnswers) {
        guard !answers.bodyConditions.isEmpty,
              !answers.sensitiveAreas.isEmpty,
              let mainGoal = answers.mainGoal,
              let postExerciseFeeling = answers.postExerciseFeeling,
              let weightStability = answers.weightStability,
              let taiChiExperience = answers.taiChiExperience,
              let taiChiIntensity = answers.taiChiIntensity,
              let dailyCommitment = answers.dailyCommitment,
              let energyLevel = answers.energyLevel,
              let heightCm = answers.heightCm,
              let weightKg = answers.currentWeightKg,
              let targetWeightKg = answers.targetWeightKg,
              let age = answers.age,
              let gender = answers.gender,
              let displayName = answers.displayName, !displayName.isEmpty,
              let activityLevel = answers.activityLevel
        else { return nil }

        bodyConditions = answers.bodyConditions
        self.mainGoal = mainGoal
        self.postExerciseFeeling = postExerciseFeeling
        self.weightStability = weightStability
        self.taiChiExperience = taiChiExperience
        self.taiChiIntensity = taiChiIntensity
        sensitiveAreas = answers.sensitiveAreas
        self.dailyCommitment = dailyCommitment
        self.energyLevel = energyLevel
        self.heightCm = heightCm
        // A pound entry converts to a long fraction of a kilogram; one decimal is plenty.
        self.weightKg = (weightKg * 10).rounded() / 10
        self.targetWeightKg = (targetWeightKg * 10).rounded() / 10
        self.age = age
        self.gender = gender
        self.displayName = displayName
        self.activityLevel = activityLevel
    }
}

private struct CreatedUserDTO: Codable {
    let deviceId: String
}

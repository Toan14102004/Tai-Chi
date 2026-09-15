//
//  PersonalDetailsViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

extension PersonalDetailsView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var profile = UserProfile()
        @Published var answers = ProfileSetupAnswers()
        @Published var isShowingImagePicker = false

        /// The design's single toggle drives both units at once ("Kg, cm" / "Lbs, ft"),
        /// so the two independent preferences in `ProfileSetupAnswers` move together here.
        var isMetric: Bool {
            answers.heightUnit == .centimeters
        }

        func load() {
            profile = localStorageService.userProfile
            answers = localStorageService.profileSetupAnswers
        }

        func setMetric(_ metric: Bool) {
            guard metric != isMetric else { return }
            answers.heightUnit = metric ? .centimeters : .feetInches
            answers.weightUnit = metric ? .kilograms : .pounds
            localStorageService.profileSetupAnswers = answers
        }

        func commitName(_ name: String) {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            profile.displayName = trimmed.isEmpty ? profile.displayName : trimmed
            localStorageService.userProfile = profile
        }

        func setAvatar(_ image: UIImage) {
            profile.avatarImageData = image.jpegData(compressionQuality: 0.85)
            localStorageService.userProfile = profile
        }

        var avatarImage: UIImage? {
            profile.avatarImageData.flatMap(UIImage.init(data:))
        }

        // MARK: - Formatted values

        var heightText: String {
            guard let cm = answers.heightCm else { return "--" }
            if isMetric { return "\(cm) cm" }
            let totalInches = Double(cm) / 2.54
            return "\(Int(totalInches) / 12)' \(Int(totalInches) % 12)\""
        }

        var weightText: String { weightText(answers.currentWeightKg) }
        var targetWeightText: String { weightText(answers.targetWeightKg) }

        private func weightText(_ kg: Double?) -> String {
            guard let kg else { return "--" }
            return isMetric
                ? "\(Int(kg.rounded())) kg"
                : "\(Int((kg * 2.20462).rounded())) lb"
        }

        func back() {
            navigation.goBack()
        }
    }
}

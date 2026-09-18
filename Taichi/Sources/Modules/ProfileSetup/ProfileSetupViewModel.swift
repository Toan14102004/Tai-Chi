//
//  ProfileSetupViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import Combine
import Foundation

extension ProfileSetupView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var deviceRegistration: DeviceRegistrationService

        @Published var coordinator = Coordinator()
        @Published var currentStep: ProfileSetupStep = .bodyConditions
        @Published var answers = ProfileSetupAnswers()

        @Published var heightText: String = ""
        @Published var heightFeetText: String = ""
        @Published var heightInchesText: String = ""
        @Published var currentWeightText: String = ""
        @Published var targetWeightText: String = ""
        @Published var ageText: String = ""
        @Published var nameText: String = ""
        @Published var showAgeError: Bool = false
        @Published var heightErrorText: String?
        @Published var currentWeightErrorText: String?
        @Published var targetWeightErrorText: String?
        @Published var registrationError: String?

        // Ranges from `GET /v1/users/onboarding/options`; the server rejects anything outside them.
        private static let heightRangeCm = 80...250
        private static let weightRangeKg = 20.0...500.0
        private static let ageRange = 13...100
        static let nameMaxLength = 100

        private var cancellables = Set<AnyCancellable>()

        var isNextEnabled: Bool {
            switch currentStep {
            case .height:
                switch answers.heightUnit {
                case .centimeters: return !heightText.isEmpty && heightErrorText == nil
                case .feetInches: return !heightFeetText.isEmpty && heightErrorText == nil
                }
            case .weight: return !currentWeightText.isEmpty && currentWeightErrorText == nil
            case .targetWeight: return !targetWeightText.isEmpty && targetWeightErrorText == nil
            case .age: return !ageText.isEmpty && !showAgeError
            case .displayName: return !trimmedName.isEmpty
            case .generatingPlan: return true
            default: return hasAnswer(for: currentStep)
            }
        }

        private func hasAnswer(for step: ProfileSetupStep) -> Bool {
            if let keyPath = step.multiAnswer { return !answers[keyPath: keyPath].isEmpty }
            if let keyPath = step.singleAnswer { return answers[keyPath: keyPath] != nil }
            return false
        }

        private var trimmedName: String {
            nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // MARK: - Progress

        /// 1-based tick out of `ProfileSetupStep.totalProgressSteps`. "Height" is two ticks (empty vs.
        /// a value entered -- the API's `figmaStates: [10, 11]`), so every later step shifts by one.
        var progressNumerator: Int {
            let base = currentStep.rawValue + 1
            if currentStep == .height {
                let hasValue = answers.heightUnit == .centimeters ? !heightText.isEmpty : !heightFeetText.isEmpty
                return hasValue ? base + 1 : base
            }
            return currentStep.rawValue > ProfileSetupStep.height.rawValue ? base + 1 : base
        }

        var progressLabel: String { "\(progressNumerator)/\(ProfileSetupStep.totalProgressSteps)" }

        var progressFraction: Double {
            Double(progressNumerator) / Double(ProfileSetupStep.totalProgressSteps)
        }

        // MARK: - Selection helpers

        func isSelected(_ value: String, in keyPath: KeyPath<ProfileSetupAnswers, String?>) -> Bool {
            answers[keyPath: keyPath] == value
        }

        func selectSingle(_ value: String, for keyPath: WritableKeyPath<ProfileSetupAnswers, String?>) {
            answers[keyPath: keyPath] = value
        }

        func isSelected(_ value: String, in keyPath: KeyPath<ProfileSetupAnswers, [String]>) -> Bool {
            answers[keyPath: keyPath].contains(value)
        }

        func toggleMulti(_ value: String, exclusiveWith exclusiveValue: String? = nil, for keyPath: WritableKeyPath<ProfileSetupAnswers, [String]>) {
            var selection = answers[keyPath: keyPath]
            if selection.contains(value) {
                selection.removeAll { $0 == value }
            } else if value == exclusiveValue {
                selection = [value]
            } else {
                selection.removeAll { $0 == exclusiveValue }
                selection.append(value)
            }
            answers[keyPath: keyPath] = selection
        }

        // MARK: - Unit conversion

        func heightUnitChanged() {
            let oldUnit: HeightUnit = answers.heightUnit == .centimeters ? .feetInches : .centimeters
            let cm: Int?
            switch oldUnit {
            case .centimeters:
                cm = Int(heightText)
            case .feetInches:
                cm = heightCm(feet: heightFeetText, inches: heightInchesText)
            }
            guard let cm else { return }
            switch answers.heightUnit {
            case .centimeters:
                heightText = "\(cm)"
            case .feetInches:
                let totalInches = Int((Double(cm) / 2.54).rounded())
                heightFeetText = "\(totalInches / 12)"
                heightInchesText = "\(totalInches % 12)"
            }
            validateHeight()
        }

        func validateHeight() {
            guard let cm = currentHeightCm() else {
                heightErrorText = nil
                return
            }
            heightErrorText = Self.heightRangeCm.contains(cm) ? nil : heightRangeErrorMessage()
        }

        /// The height currently entered, in cm, regardless of which unit is displayed.
        private func currentHeightCm() -> Int? {
            switch answers.heightUnit {
            case .centimeters:
                guard !heightText.isEmpty else { return nil }
                return Int(heightText)
            case .feetInches:
                return heightCm(feet: heightFeetText, inches: heightInchesText)
            }
        }

        private func heightCm(feet: String, inches: String) -> Int? {
            guard !feet.isEmpty || !inches.isEmpty else { return nil }
            let totalInches = (Int(feet) ?? 0) * 12 + (Int(inches) ?? 0)
            return Int((Double(totalInches) * 2.54).rounded())
        }

        /// The `heightRangeCm` bounds converted to whole feet/inches, for display purposes only --
        /// validation itself always happens in cm so both units share one source of truth.
        private func heightRangeErrorMessage() -> String {
            switch answers.heightUnit {
            case .centimeters:
                return "Height must be \(Self.heightRangeCm.lowerBound)-\(Self.heightRangeCm.upperBound) cm"
            case .feetInches:
                let minInches = Int((Double(Self.heightRangeCm.lowerBound) / 2.54).rounded())
                let maxInches = Int((Double(Self.heightRangeCm.upperBound) / 2.54).rounded())
                return "Height must be \(minInches / 12) ft \(minInches % 12) in - \(maxInches / 12) ft \(maxInches % 12) in"
            }
        }

        func weightUnitChanged(text: inout String) {
            guard let kg = parsedWeightKg(from: text, unit: answers.weightUnit == .kilograms ? .pounds : .kilograms) else { return }
            text = answers.weightUnit == .kilograms ? "\(Int(kg.rounded()))" : "\(Int((kg * 2.20462).rounded()))"
        }

        func validateWeight(_ text: String, errorBinding: inout String?) {
            guard !text.isEmpty, let kg = parsedWeightKg(from: text, unit: answers.weightUnit) else {
                errorBinding = nil
                return
            }
            errorBinding = Self.weightRangeKg.contains(kg) ? nil : "Weight must be 20-500 kg"
        }

        private func parsedWeightKg(from text: String, unit: WeightUnit) -> Double? {
            guard let raw = Double(text) else { return nil }
            switch unit {
            case .kilograms: return raw
            case .pounds: return raw * 0.453592
            }
        }

        // MARK: - Navigation

        func back() {
            guard let previous = ProfileSetupStep(rawValue: currentStep.rawValue - 1) else {
                navigator.goBack()
                return
            }
            currentStep = previous
        }

        func next() {
            switch currentStep {
            case .height:
                validateHeight()
                guard heightErrorText == nil else { return }
                answers.heightCm = currentHeightCm()
            case .weight:
                validateWeight(currentWeightText, errorBinding: &currentWeightErrorText)
                guard currentWeightErrorText == nil else { return }
                answers.currentWeightKg = parsedWeightKg(from: currentWeightText, unit: answers.weightUnit)
            case .targetWeight:
                validateWeight(targetWeightText, errorBinding: &targetWeightErrorText)
                guard targetWeightErrorText == nil else { return }
                answers.targetWeightKg = parsedWeightKg(from: targetWeightText, unit: answers.weightUnit)
            case .age:
                guard let age = Int(ageText), Self.ageRange.contains(age) else {
                    showAgeError = true
                    return
                }
                showAgeError = false
                answers.age = age
            case .displayName:
                answers.displayName = String(trimmedName.prefix(Self.nameMaxLength))
            default:
                break
            }

            guard let nextStep = ProfileSetupStep(rawValue: currentStep.rawValue + 1) else {
                return
            }
            currentStep = nextStep

            if nextStep == .generatingPlan {
                localStorageService.profileSetupAnswers = answers
                submitProfile()
            }
        }

        /// Creates the server-side user every plan endpoint needs. The "generating" screen stays up
        /// for at least its animation's length even when the server answers faster.
        func submitProfile() {
            registrationError = nil

            Publishers.Zip(
                deviceRegistration.register(answers: answers),
                Just(())
                    .delay(for: .seconds(2.2), scheduler: DispatchQueue.main)
                    .setFailureType(to: NetworkError.self)
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.registrationError = error.errorDescription
                }
            } receiveValue: { [weak self] _ in
                self?.finishSetup()
            }
            .store(in: &cancellables)
        }

        private func finishSetup() {
            // This is the one paywall the app opens without first checking whether the user
            // is a subscriber, so it needs the flag directly. Land on the same screen that
            // closing the paywall would have led to, rather than stranding the user on the
            // finished "generating plan" step.
            guard AppFlags.iapEnabled else {
                navigator.push(RootView.Coordinator.Navigation.content)
                return
            }

            navigator.presentCover(
                RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .onboarding),
                withNavigation: true
            )
        }
    }
}

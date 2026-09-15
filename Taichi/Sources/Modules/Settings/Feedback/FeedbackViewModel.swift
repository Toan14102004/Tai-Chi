//
//  FeedbackViewModel.swift
//  Taichi
//
//  Created by Minh Hieu on 7/9/25.
//

import SwiftUI

enum AnswerOption: String {
    case yes = "Yes"
    case no = "No"
}

class FeedbackViewModel: ObservableObject {
    @Published var details: String = ""
    @Published var selectedAnswer: AnswerOption = .yes
    @Published var isSubmitting: Bool = false
    @Published var feedbackText: String = ""

    @Navigation var navigation

    func goBack() {
        navigation.pop()
    }

    var isFormValid: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSubmit: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func selectAnswer(_ answer: AnswerOption) {
        selectedAnswer = answer
    }

    func submitFeedback() {
        isSubmitting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSubmitting = false
            self.goBack()
        }
    }
}

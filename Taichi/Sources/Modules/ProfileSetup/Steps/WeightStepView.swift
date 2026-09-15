//
//  WeightStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

/// Shared body for the "Current Weight" and "Target Weight" steps — same input shape,
/// different backing text binding, same `weightUnit` preference.
struct WeightStepView: View {
    enum WeightType { case current, target }

    @ObservedObject var viewModel: ProfileSetupView.ViewModel
    let text: Binding<String>
    let type: WeightType

    var errorText: String? {
        type == .current ? viewModel.currentWeightErrorText : viewModel.targetWeightErrorText
    }

    var body: some View {
        ProfileSetupNumberInputCard(text: text, errorText: errorText) {
            ProfileSetupUnitToggle(
                options: [(WeightUnit.kilograms, "kg"), (WeightUnit.pounds, "Lbs")],
                selection: Binding(
                    get: { viewModel.answers.weightUnit },
                    set: { newValue in
                        guard newValue != viewModel.answers.weightUnit else { return }
                        viewModel.answers.weightUnit = newValue
                        var mutableText = text.wrappedValue
                        viewModel.weightUnitChanged(text: &mutableText)
                        text.wrappedValue = mutableText
                    }
                )
            )
            .frame(width: 160)
        }
        .onChange(of: text.wrappedValue) { _ in
            if type == .current {
                viewModel.validateWeight(text.wrappedValue, errorBinding: &viewModel.currentWeightErrorText)
            } else {
                viewModel.validateWeight(text.wrappedValue, errorBinding: &viewModel.targetWeightErrorText)
            }
        }
    }
}

//
//  HeightStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct HeightStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel

    var body: some View {
        ProfileSetupNumberInputCard(text: $viewModel.heightText, errorText: viewModel.heightErrorText) {
            ProfileSetupUnitToggle(
                options: [(HeightUnit.centimeters, "cm"), (HeightUnit.feetInches, "ft & in")],
                selection: Binding(
                    get: { viewModel.answers.heightUnit },
                    set: { newValue in
                        guard newValue != viewModel.answers.heightUnit else { return }
                        viewModel.answers.heightUnit = newValue
                        viewModel.heightUnitChanged()
                    }
                )
            )
            .frame(width: 168)
        }
        .onChange(of: viewModel.heightText) { _ in
            viewModel.validateHeight()
        }
    }
}

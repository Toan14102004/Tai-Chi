//
//  AgeStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct AgeStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel

    var body: some View {
        ProfileSetupNumberInputCard(
            text: $viewModel.ageText,
            errorText: viewModel.showAgeError ? "Enter a valid age." : nil
        ) {
            Text("Years")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
        }
        .onChange(of: viewModel.ageText) { _ in viewModel.showAgeError = false }
    }
}

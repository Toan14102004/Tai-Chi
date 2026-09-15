//
//  NameStepView.swift
//  Taichi
//

import SwiftUI

struct NameStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: $viewModel.nameText, prompt: Text("Your name").foregroundColor(Asset.Color.textTertiary.color))
            .font(Typography.headlineLarge)
            .foregroundStyle(Asset.Color.textPrimary.color)
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($isFocused)
            .onSubmit {
                if viewModel.isNextEnabled { viewModel.next() }
            }
            .onChange(of: viewModel.nameText) { newValue in
                let limit = ProfileSetupView.ViewModel.nameMaxLength
                if newValue.count > limit {
                    viewModel.nameText = String(newValue.prefix(limit))
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
            .onAppear { isFocused = true }
    }
}

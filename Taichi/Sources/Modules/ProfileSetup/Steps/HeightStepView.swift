//
//  HeightStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct HeightStepView: View {
    @ObservedObject var viewModel: ProfileSetupView.ViewModel
    @FocusState private var isFeetFieldFocused: Bool

    var body: some View {
        Group {
            switch viewModel.answers.heightUnit {
            case .centimeters:
                ProfileSetupNumberInputCard(text: $viewModel.heightText, errorText: viewModel.heightErrorText) {
                    unitToggle
                }
                .onChange(of: viewModel.heightText) { _ in
                    viewModel.limitHeightInput()
                    viewModel.validateHeight()
                }
            case .feetInches:
                feetInchesCard
            }
        }
    }

    private var unitToggle: some View {
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

    private var feetInchesCard: some View {
        VStack(spacing: Layout.Spacing.m) {
            HStack(spacing: Layout.Spacing.m) {
                feetInchesField(text: $viewModel.heightFeetText, unit: "ft", isFocused: $isFeetFieldFocused)
                feetInchesField(text: $viewModel.heightInchesText, unit: "in", isFocused: nil)
            }

            unitToggle

            if let errorText = viewModel.heightErrorText {
                Text(errorText.localizedKey)
                    .font(Typography.labelSmall)
                    .foregroundStyle(Color(hex: "#EB4646"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Layout.Spacing.m)
        .onAppear { isFeetFieldFocused = true }
    }

    private func feetInchesField(text: Binding<String>, unit: String, isFocused: FocusState<Bool>.Binding?) -> some View {
        HStack(spacing: Layout.Spacing.xs) {
            ZStack {
                Text(text.wrappedValue.isEmpty ? "0" : text.wrappedValue)
                    .font(Typography.headlineLarge)
                    .foregroundStyle(
                        text.wrappedValue.isEmpty ? Asset.Color.textTertiary.color : Asset.Color.textPrimary.color
                    )

                TextField("", text: text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .opacity(0.02)
                    .modifier(OptionalFocus(isFocused: isFocused))
                    .onChange(of: text.wrappedValue) { newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered != newValue { text.wrappedValue = filtered }
                        viewModel.limitHeightInput()
                        viewModel.validateHeight()
                    }
            }

            Text(unit)
                .font(Typography.headlineLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
    }
}

/// Applies `.focused` only when the caller supplies a `FocusState` binding, so the shared
/// `feetInchesField` builder can leave the "in" field out of the initial-focus chain.
private struct OptionalFocus: ViewModifier {
    let isFocused: FocusState<Bool>.Binding?

    func body(content: Content) -> some View {
        if let isFocused {
            content.focused(isFocused)
        } else {
            content
        }
    }
}

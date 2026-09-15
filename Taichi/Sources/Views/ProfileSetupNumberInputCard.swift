//
//  ProfileSetupNumberInputCard.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

/// Big centered numeric value with a hidden text field driving real keyboard input,
/// an optional unit-toggle row below it, and an optional inline validation error.
struct ProfileSetupNumberInputCard<UnitContent: View>: View {
    @Binding var text: String
    var placeholder: String = "0"
    var errorText: String?
    @ViewBuilder var unitContent: () -> UnitContent

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            ZStack {
                Text(text.isEmpty ? placeholder : text)
                    .font(Typography.headlineLarge)
                    .foregroundStyle(
                        text.isEmpty ? Asset.Color.textTertiary.color : Asset.Color.textPrimary.color
                    )

                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .opacity(0.02)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered != newValue { text = filtered }
                    }
            }

            unitContent()

            if let errorText {
                Text(errorText.localizedKey)
                    .font(Typography.labelSmall)
                    .foregroundStyle(Color(hex: "#EB4646"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Layout.Spacing.m)
        .onAppear { isFocused = true }
    }
}

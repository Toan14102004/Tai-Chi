//
//  ProgressCalorieGoalSheet.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProgressCalorieGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    let save: (Int) -> Void

    init(value: Int, save: @escaping (Int) -> Void) {
        _text = State(initialValue: String(value))
        self.save = save
    }

    private var currentValue: Int {
        Int(text) ?? 0
    }

    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            ZStack {
                Text("Calories Goal")
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                HStack {
                    Spacer()
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Asset.Color.textPrimary.color)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: Layout.Spacing.m) {
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 52, height: 52)
                        .background(
                            Circle()
                                .stroke(Asset.Color.borderPrimary.color, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                TextField("Goal", text: $text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32.iPad(36), weight: .bold))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .frame(maxWidth: .infinity)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 52, height: 52)
                        .background(
                            Circle()
                                .stroke(Asset.Color.borderPrimary.color, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Layout.Spacing.s)

            HStack(spacing: Layout.Spacing.s) {
                Button("Cancel", action: dismiss.callAsFunction)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Asset.Color.mainColor.color, lineWidth: 1)
                    )

                Button("Save") {
                    save(currentValue)
                    dismiss()
                }
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Asset.Color.mainColor.color, in: RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
            }
        }
        .padding(Layout.Spacing.l)
    }

    private func increment() {
        text = String(currentValue + 5)
    }

    private func decrement() {
        let newValue = max(0, currentValue - 10)
        text = String(newValue)
    }
}

//
//  DurationStepper.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The "Duration  −  01:00  +" row on the Exercise Detail edit screen.
struct DurationStepper: View {
    @Binding var seconds: Int
    var step: Int = 5
    var minimumSeconds: Int = 5

    private var label: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        HStack {
            Text("Duration")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)

            Spacer()

            HStack(spacing: 16) {
                stepButton(systemImage: "minus") { seconds = max(minimumSeconds, seconds - step) }

                Text(label)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .frame(minWidth: 44)

                stepButton(systemImage: "plus") { seconds += step }
            }
        }
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .frame(width: 28, height: 28)
                .background(Color(hex: "#F2F2F2"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

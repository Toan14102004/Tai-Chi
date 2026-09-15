//
//  AddReminderTimeSheet.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Figma: FLow Profile / 06 — Add Reminder Time.
/// A 375x438 white sheet: title, a five-row time wheel, then Cancel / Done.
struct AddReminderTimeSheet: View {
    let onCancel: () -> Void
    let onDone: (Int, Int) -> Void

    @State private var hour: Int
    @State private var minute: Int

    private let hours = Array(0..<24)
    private let minutes = Array(0..<60)

    init(initialHour: Int = 7, initialMinute: Int = 0, onCancel: @escaping () -> Void, onDone: @escaping (Int, Int) -> Void) {
        _hour = State(initialValue: initialHour)
        _minute = State(initialValue: initialMinute)
        self.onCancel = onCancel
        self.onDone = onDone
    }

    var body: some View {
        VStack(spacing: Layout.Spacing.xl) {
            Text("Reminder")
                .font(Typography.subtitleLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            wheels

            HStack(spacing: Layout.Spacing.s + 2) {
                actionButton("Cancel", isPrimary: false, action: onCancel)
                actionButton("Done", isPrimary: true) { onDone(hour, minute) }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.vertical, Layout.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Asset.Color.white.color)
    }

    /// The highlight sits behind both columns so it reads as one 44pt row, as drawn in Figma.
    private var wheels: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Asset.Color.rowSelected.color)
                .frame(height: NumberWheel.rowHeight)

            HStack(spacing: Layout.Spacing.xl) {
                NumberWheel(values: hours, selection: $hour)
                NumberWheel(values: minutes, selection: $minute)
            }
        }
        .frame(height: NumberWheel.rowHeight * 5)
        .padding(.top, Layout.Spacing.m)
    }

    private func actionButton(_ title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(isPrimary ? Asset.Color.white.color : Asset.Color.mainColor.color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(isPrimary ? Asset.Color.mainColor.color : Asset.Color.white.color)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Asset.Color.mainColor.color, lineWidth: isPrimary ? 0 : 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

//
//  ReminderCard.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// One saved reminder: time, on/off switch, the seven day chips, and the "Every day" shortcut.
struct ReminderCard: View {
    let reminder: WorkoutReminder
    let onToggle: () -> Void
    let onToggleWeekday: (Int) -> Void
    let onToggleEveryDay: () -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            HStack {
                Text(reminder.timeText)
                    .font(FontFamily.Inter.medium.font(size: 32))
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                switchControl
            }

            HStack(spacing: Layout.Spacing.m) {
                ForEach(WorkoutReminder.weekdaySymbols, id: \.weekday) { symbol in
                    WeekdayChip(
                        label: symbol.label,
                        isOn: reminder.weekdays.contains(symbol.weekday)
                    ) {
                        onToggleWeekday(symbol.weekday)
                    }
                }
            }

            Button(action: onToggleEveryDay) {
                HStack {
                    Text("Every day")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textNavy.color)

                    Spacer()

                    if reminder.isEveryDay {
                        Asset.Icon.Profile.tickCircle.image
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Asset.Icon.Profile.radioCircle.image
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.top, Layout.Spacing.s)
            }
            .buttonStyle(.plain)
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    /// The design's switch is smaller than `Toggle`'s fixed 51x31, so it is drawn by hand.
    private var switchControl: some View {
        Button(action: onToggle) {
            ZStack(alignment: reminder.isEnabled ? .trailing : .leading) {
                Capsule()
                    .fill(reminder.isEnabled ? Asset.Color.toggleTrackOn.color : Asset.Color.trackInactive.color)
                    .frame(width: 34, height: 14)

                Circle()
                    .fill(reminder.isEnabled ? Asset.Color.mainColor.color : Asset.Color.gray.color)
                    .frame(width: 20, height: 20)
            }
            .frame(width: 37, height: 20)
            .animation(.easeInOut(duration: 0.15), value: reminder.isEnabled)
        }
        .buttonStyle(.plain)
    }
}

//
//  WorkoutStatsRow.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// The Level / Kcal / Net Duration line under a workout title, shared by the Workout Day screen
/// and the Discover workout screen.
///
/// The calorie column is dropped when the workout has no figure: `/workouts/{id}` carries one for
/// Discover workouts but a program day does not, and the design has no empty state for it.
struct WorkoutStatsRow: View {
    let day: WorkoutDay

    var body: some View {
        HStack {
            column(value: day.level, label: "Level")
            Spacer()
            if let kcal = day.kcal {
                column(value: String(format: "%.1f", kcal), label: "Kcal")
                Spacer()
            }
            column(value: "\(day.netDurationMinutes) min", label: "Net Duration")
        }
    }

    private func column(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text(label)
                .font(Typography.labelSmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
    }
}

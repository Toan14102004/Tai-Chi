//
//  InstructionsSheet.swift
//  Taichi
//
//  Created by Toan Nguyen on 15/9/26.
//

import SwiftUI

/// Generic "how to do it" sheet: full-width image, title, and any of "How to Do"/"Common
/// Mistakes"/"Breathing Tips"/"Guidance" the caller has -- nothing here is specific to Tai Chi.
/// Presented via `RootView.Coordinator.FullScreen.exerciseInstructions` and
/// `navigator.presentSheet(...)`; the `WorkoutExercise` convenience init below is the one
/// domain-specific piece, kept separate so this type stays reusable as-is in another app.
struct InstructionsSheet: View {
    let title: String
    let imageUrl: URL?
    let howTo: [String]
    let commonMistakes: [String]
    let breathingTips: [String]
    let guidance: String

    @Navigation var navigator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Full sheet width, flush against the sides -- only the top corners are rounded,
                // matching the sheet's own top edge.
                ZStack(alignment: .topTrailing) {
                    // `.fit`, not `.fill`, and no fixed height: a wide-armed pose at full sheet
                    // width would otherwise scale up enough that `.fill` crops the head and feet
                    // off to cover the width. Sizing to the image's own aspect ratio instead shows
                    // the whole figure; the sheet is a ScrollView, so extra height just scrolls.
                    RemoteImageView(url: imageUrl, contentMode: .fit)
                        .cornerRadius(radius: Layout.CornerRadius.large, corners: [.topLeft, .topRight])

                    Button { navigator.goBack() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Asset.Color.white.color)
                            .padding(Layout.Spacing.s)
                            .background(.black.opacity(Layout.Opacity.medium))
                            .clipShape(Circle())
                    }
                    .padding(Layout.Spacing.s)
                }
                .padding(.top, Layout.Spacing.s)

                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    Text(title)
                        .font(Typography.headlineSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    bulletSection(title: "How to Do", items: howTo)
                    bulletSection(title: "Common Mistakes", items: commonMistakes)
                    bulletSection(title: "Breathing Tips", items: breathingTips)

                    if !guidance.isEmpty {
                        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                            Text("Guidance")
                                .font(Typography.subtitleSmall)
                                .foregroundStyle(Asset.Color.textPrimary.color)

                            Text(guidance)
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Asset.Color.textSecondary.color)
                        }
                    }
                }
                .padding(Layout.Spacing.m)
            }
        }
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        // Matches DiscoverWorkoutView/WorkoutDayView's sheets: draggable between half and (near)
        // full height rather than stuck at whatever the system's single default detent is.
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func bulletSection(title: String, items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                Text(title)
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: Layout.Spacing.xs) {
                        Text("•")
                        Text(item)
                    }
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }
        }
    }
}

extension InstructionsSheet {
    init(exercise: WorkoutExercise) {
        title = exercise.name
        imageUrl = exercise.imageUrl
        howTo = exercise.howTo
        commonMistakes = exercise.commonMistakes
        breathingTips = exercise.breathingTips
        guidance = exercise.guidance
    }
}

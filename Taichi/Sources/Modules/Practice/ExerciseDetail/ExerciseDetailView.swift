//
//  ExerciseDetailView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct ExerciseDetailView: View {
    @StateObject private var viewModel: ViewModel

    init(workoutId: String, initialExerciseId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(
            workoutId: workoutId,
            initialExerciseId: initialExerciseId
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                hero
                    .frame(width: UIScreen.main.bounds.width,
                           height: Layout.heroHeight + UIApplication.shared.safeAreaTop)
                    .clipped()

                HeroOverlayButton(image: Asset.Icon.Commo.xmark, iconSize: 12, action: viewModel.close)
                    .padding(Layout.Spacing.m)
                    .padding(.top, UIApplication.shared.safeAreaTop)
            }
            .clipped()
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.exercise == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, Layout.Spacing.xxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.exercise == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let exercise = viewModel.exercise {
                        content(exercise)
                    }
                }
                .padding(Layout.Spacing.m)
            }
            .onChange(of: viewModel.draftDurationSeconds) { _ in
                if viewModel.draftDurationSeconds != viewModel.exercise?.durationSeconds {
                    viewModel.isEditingDuration = true
                }
            }

            if viewModel.exercise != nil {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .onDisappear(perform: viewModel.stopMusic)
        .trackScreen("exerciseDetailVC")
    }

    /// The API ships a short demo clip for essentially every exercise; the still image is only a
    /// fallback for the few that have none.
    @ViewBuilder
    private var hero: some View {
        if let videoUrl = viewModel.exercise?.videoUrl {
            ExerciseVideoPlayer(url: videoUrl, onPlaybackStateChange: viewModel.handleClipPlaybackChange, onPlaybackEnded: viewModel.handleClipPlaybackEnded)
                .id(videoUrl)
        } else {
            RemoteImageView(url: viewModel.exercise?.imageUrl)
        }
    }

    @ViewBuilder
    private func content(_ exercise: WorkoutExercise) -> some View {
        Text(exercise.name)
            .font(Typography.headlineMedium)
            .foregroundStyle(Asset.Color.textPrimary.color)

        DurationStepper(seconds: $viewModel.draftDurationSeconds)

        bulletSection(title: "How to Do", items: exercise.howTo)
        bulletSection(title: "Common Mistakes", items: exercise.commonMistakes)
        bulletSection(title: "Breathing Tips", items: exercise.breathingTips)
        guidanceSection(exercise.guidance)
    }

    @ViewBuilder
    private func guidanceSection(_ text: String) -> some View {
        if !text.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Guidance")
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Text(text)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }
        }
    }

    @ViewBuilder
    private func bulletSection(title: String, items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                // Figma renders these as a single paragraph, one point per line with no bullet
                // glyph -- the API's own line breaks already carry that structure.
                Text(items.joined(separator: "\n"))
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }
        }
    }

    private var footer: some View {
        Group {
            if viewModel.isEditingDuration {
                HStack(spacing: Layout.Spacing.s) {
                    Button("Reset", action: viewModel.resetDraft)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.mainColor.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Asset.Color.mainColor.color, lineWidth: 1))

                    Button("Save", action: viewModel.save)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.white.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Asset.Color.mainColor.color)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            } else {
                // The three pieces sit grouped and centred, per Figma -- not spread across the
                // full width the way a leading/trailing pager usually lays out.
                HStack(spacing: 26) {
                    pagerButton(systemImage: "chevron.left",
                               background: Asset.Color.white.color,
                               tint: Asset.Color.textTertiary.color,
                               action: viewModel.goPrevious,
                               enabled: viewModel.canGoPrevious)

                    Text(viewModel.paginationLabel)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    pagerButton(systemImage: "chevron.right",
                               background: Color(hex: "#FFCFC6"),
                               tint: Asset.Color.mainColor.color,
                               action: viewModel.goNext,
                               enabled: viewModel.canGoNext)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, Layout.Spacing.s)
        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }

    private func pagerButton(systemImage: String,
                             background: Color,
                             tint: Color,
                             action: @escaping () -> Void,
                             enabled: Bool) -> some View
    {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(background)
                .clipShape(Circle())
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
}

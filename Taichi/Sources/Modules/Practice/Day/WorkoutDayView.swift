//
//  WorkoutDayView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct WorkoutDayView: View {
    @StateObject private var viewModel: ViewModel

    init(workoutId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(workoutId: workoutId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        // The hero runs edge to edge behind the status bar, so its height carries
                        // the safe-area inset on top of the 220pt the design shows below it.
                        RemoteImageView(url: viewModel.day?.imageUrl)
                            .frame(width: UIScreen.main.bounds.width,
                                   height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

                        HStack {
                            HeroOverlayButton(image: Asset.Icon.ProfileSetup.backChevron, action: viewModel.back)
                            Spacer()
                            HeroOverlaySettingsButton(action: viewModel.openSettings)
                        }
                        .padding(Layout.Spacing.m)
                        .padding(.top, UIApplication.shared.safeAreaTop)
                    }
                    .clipped()

                    VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                        PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                        if viewModel.isLoading, viewModel.day == nil {
                            WorkoutDetailSkeletonView()
                        } else if let errorMessage = viewModel.errorMessage, viewModel.day == nil {
                            WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                        } else if let day = viewModel.day {
                            content(day)
                        }
                    }
                    .padding(Layout.Spacing.m)
                }
            }
            .ignoresSafeArea(edges: .top)

            if viewModel.day != nil {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .sheet(isPresented: $viewModel.showSettings) {
            WorkoutSettingsSheet(viewModel: .init())
                .presentationDetents([.large])
        }
        .trackScreen("workoutDayVC")
    }

    @ViewBuilder
    private func content(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
            Text(day.dayNumber > 0 ? "Day \(day.dayNumber)" : day.title)
                .font(Typography.headlineLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text(day.description)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }

        WorkoutStatsRow(day: day)

        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises (\(day.displayExerciseCount))")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)

            VStack(spacing: Layout.Spacing.s) {
                ForEach(day.exercises) { exercise in
                    WorkoutExerciseRow(
                        imageUrl: exercise.imageUrl ?? day.imageUrl,
                        title: exercise.name,
                        subtitle: exercise.durationLabel,
                        isCompleted: viewModel.isCompleted(exercise),
                        action: { viewModel.openExercise(exercise) }
                    )
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: Layout.Spacing.s) {
            if viewModel.hasStarted {
                Button("Restart", action: viewModel.restart)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Asset.Color.mainColor.color, lineWidth: 1.5))
            }

            Button(viewModel.hasStarted ? "Continue" : "Start Now", action: viewModel.startOrContinue)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        // The design insets the footer well past the content margin -- 296pt of button on a 375pt
        // screen (Figma 2027:624 -> `button`).
        .padding(.horizontal, Layout.footerInset)
        .padding(.top, Layout.Spacing.s)
//        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }
}

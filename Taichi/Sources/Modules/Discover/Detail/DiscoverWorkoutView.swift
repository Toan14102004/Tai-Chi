//
//  DiscoverWorkoutView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// A workout opened from Discover. Unlike a program day, its exercise list starts locked: the
/// rows show only their position until the user watches a rewarded ad or subscribes.
struct DiscoverWorkoutView: View {
    // Observed, not read: the lock state is derived from the subscription, and buying premium
    // happens on a screen presented over this one. Without this the list would still be drawn
    // locked when the user came back.
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel: ViewModel

    init(workoutId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(workoutId: workoutId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    hero

                    VStack(alignment: .leading, spacing: Layout.Spacing.m) {
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
        .popup(isPresented: $viewModel.showUnlockDialog) {
            WorkoutUnlockDialog(
                getPremium: viewModel.openPremium,
                watchAds: viewModel.unlockWithAds,
                close: viewModel.dismissUnlockDialog
            )
        } customize: { params in
            params
                .centerPopup()
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(Layout.Opacity.semiTransparent))
        }
        .trackScreen("discoverWorkoutVC")
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .top) {
            // Runs edge to edge behind the status bar, so its height carries the safe-area inset
            // on top of the 220pt the design shows below it.
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
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Content

    @ViewBuilder
    private func content(_ day: WorkoutDay) -> some View {
        Text(day.title)
            .font(Typography.headlineMedium)
            .foregroundStyle(Asset.Color.textPrimary.color)

        WorkoutStatsRow(day: day)

        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises (\(day.displayExerciseCount))")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)

            if viewModel.isUnlocked {
                exerciseList(day)
            } else {
                lockedList
            }
        }
    }

    private func exerciseList(_ day: WorkoutDay) -> some View {
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

    private var lockedList: some View {
        // Rows butt against each other and are separated by a hairline, per the design -- unlike
        // the unlocked list, which is spaced.
        VStack(spacing: 0) {
            ForEach(1 ... max(viewModel.lockedRowCount, 1), id: \.self) { position in
                LockedExerciseRow(position: position, action: viewModel.requestUnlock)
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        Button(action: viewModel.startOrUnlock) {
            HStack(spacing: Layout.Spacing.s) {
                if !viewModel.isUnlocked {
                    Asset.Icon.Discover.lockWhite.image
                        .toIcon(24)
                }

                Text(viewModel.footerTitle.localizedKey)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Asset.Color.mainColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        // The design centres a 296pt button on a 375pt screen rather than running it to the
        // content margin (Figma 2092:2587 -> `button`).
        .padding(.horizontal, Layout.footerInset)
        .padding(.top, Layout.Spacing.s)
    }
}

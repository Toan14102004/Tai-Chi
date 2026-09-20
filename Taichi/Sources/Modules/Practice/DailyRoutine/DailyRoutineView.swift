//
//  DailyRoutineView.swift
//  Taichi
//
//  One routine's fixed session list -- behind a "Daily Routine" card on the Plan tab.
//  Figma `07-challenge.md` -> `01/ Daily Routine` (node 4082:7087).
//

import SwiftUI

struct DailyRoutineView: View {
    @StateObject private var viewModel: ViewModel

    init(routineId: String, title: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(routineId: routineId, title: title))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                // Every child insets itself 16pt; the stack carries no padding of its own.
                VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
                        .padding(.horizontal, Layout.Spacing.m)

                    if viewModel.isLoading, !viewModel.hasLoaded {
                        DailyRoutineSkeletonView()
                            .padding(.horizontal, Layout.Spacing.m)
                    } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                            .padding(.horizontal, Layout.Spacing.m)
                    } else {
                        header
                        sessionList
                    }
                }
                .padding(.vertical, Layout.Spacing.m)
            }
        }
        .ignoresSafeArea(edges: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("dailyRoutineVC")
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .top) {
            // Edge to edge behind the status bar, like the Workout Day hero: the design's 263 pt
            // is the 220 below the status bar plus its inset.
            RemoteImageView(url: viewModel.imageUrl)
                .frame(width: UIScreen.main.bounds.width,
                       height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

            HStack {
                HeroOverlayButton(image: Asset.Icon.ProfileSetup.backChevron, action: viewModel.back)
                Spacer()
            }
            .padding(Layout.Spacing.m)
            .padding(.top, UIApplication.shared.safeAreaTop)
        }
        .clipped()
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Title

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.title)
                .font(Typography.headlineMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)

            Text("\(viewModel.sessionCount) Sessions")
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
        .padding(.horizontal, Layout.Spacing.m)
    }

    // MARK: - Sessions

    private var sessionList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.items) { workout in
                PicksWorkoutRow(workout: workout) {
                    viewModel.openWorkout(workout)
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}

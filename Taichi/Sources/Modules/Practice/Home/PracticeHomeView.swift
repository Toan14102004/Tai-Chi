//
//  PracticeHomeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct PracticeHomeView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.Spacing.m) {
                if viewModel.isLoading, !viewModel.hasLoaded {
                    // No outer padding here: PlanHomeSkeletonView already pads each section
                    // itself, same as the real content below it -- adding it again here would
                    // double it up (32pt instead of 16pt) and misalign the skeleton.
                    PlanHomeSkeletonView()
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                    WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                        .padding(.horizontal, Layout.Spacing.m)
                } else {
                    yourPlanSection

                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
                        .padding(.horizontal, Layout.Spacing.m)

                    dailyRoutineSection

                    picksForTodaySection
                }
            }
            .padding(.bottom, 64 + Layout.Spacing.m)
        }
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("practiceHomeVC")
    }

    // MARK: - Your Plan

    @ViewBuilder
    private var yourPlanSection: some View {
        if let plan = viewModel.currentPlan {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderRow(title: "Your Plan")
                    .padding(.horizontal, Layout.Spacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PlanHeroCard.cardSpacing) {
                        PlanHeroCard(
                            imageUrl: plan.currentDay?.imageUrl,
                            title: plan.title,
                            durationText: plan.durationText,
                            exercisesText: plan.exercisesText,
                            buttonTitle: plan.buttonTitle,
                            action: { viewModel.openPlan(plan) }
                        )
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }
            }
        }
    }

    // MARK: - Daily routines

    @ViewBuilder
    private var dailyRoutineSection: some View {
        if !viewModel.dailyRoutines.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderRow(title: "Daily Routine")
                    .padding(.horizontal, Layout.Spacing.m)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DailyRoutineCard.cardSpacing) {
                        ForEach(viewModel.dailyRoutines) { routine in
                            DailyRoutineCard(
                                imageUrl: routine.imageUrl,
                                title: routine.title,
                                action: { viewModel.openRoutine(routine) }
                            )
                        }
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }
            }
        }
    }

    // MARK: - Picks for today

    @ViewBuilder
    private var picksForTodaySection: some View {
        if !viewModel.justForYou.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderRow(title: "Picks for today")

                VStack(spacing: 12) {
                    ForEach(viewModel.justForYou) { workout in
                        PicksWorkoutRow(workout: workout, action: { viewModel.openWorkout(workout) })
                    }
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
    }
}

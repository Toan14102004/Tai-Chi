//
//  WorkoutSessionView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Lottie
import SwiftUI

/// The guided workout, following the Flow Practice screens in Figma: a Get ready countdown, then
/// each exercise with its clip looping against a timer, rest intervals that preview what is next,
/// a pause screen offering a way out, and a completion screen.
///
/// Colours and metrics are read off design screenshots -- the Figma API is still rate limited --
/// so the accent below is an approximation to re-verify.
struct WorkoutSessionView: View {
    /// The timer and headings use a violet that is not in the asset catalogue yet.
    static let accent = Color(hex: "#6C5DD3")

    @StateObject private var viewModel: ViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(workoutId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(workoutId: workoutId))
    }

    var body: some View {
        ZStack {
            Asset.Color.bgPrimary.color.ignoresSafeArea()

            if viewModel.isLoading, viewModel.exercises.isEmpty {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.exercises.isEmpty {
                WorkoutErrorView(message: errorMessage, retry: viewModel.load)
            } else {
                content
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .onChange(of: scenePhase) { phase in
            viewModel.handleScenePhaseChange(isActive: phase == .active)
        }
        .trackScreen("workoutSessionVC")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.showsPauseOptions {
            pauseOptions
        } else if viewModel.phase == .completed {
            completed
        } else {
            running
        }
    }

    // MARK: - Get ready / Exercise / Rest

    private var running: some View {
        VStack(spacing: 0) {
            hero

            VStack(spacing: Layout.Spacing.l) {
                switch viewModel.phase {
                case .getReady:
                    getReadyBody
                case .rest:
                    restBody
                default:
                    exerciseBody
                }

                Spacer(minLength: 0)

                PreloadedNativeAdsView(adKey: .practiceCompact,
                                       style: .contentCard,
                                       height: NativeAdViewStyle.contentCard.height)
            }
            .padding(Layout.Spacing.m)
        }
    }

    private var hero: some View {
        ZStack(alignment: .top) {
            clip
                .frame(width: UIScreen.main.bounds.width,
                       height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

            HStack {
                HeroOverlayButton(image: Asset.Icon.Commo.arrowLeft, action: viewModel.requestExit)
                Spacer()
            }
            .padding(Layout.Spacing.m)
            .padding(.top, UIApplication.shared.safeAreaTop)
        }
        // Without an explicit height here, the centered countdown's `maxHeight: .infinity` lets
        // this ZStack grow to whatever its parent VStack offers.
        .frame(width: UIScreen.main.bounds.width, height: Layout.heroHeight + UIApplication.shared.safeAreaTop)
        .clipped()
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var clip: some View {
        if let url = viewModel.displayedExercise?.videoUrl {
            // Keyed on the exercise, not the phase, so flipping Get ready -> Exercise resumes the
            // same player from its first frame instead of building a new one.
            ExerciseVideoPlayer(url: url, mode: .session(isPaused: !viewModel.isClipPlaying))
                .id(viewModel.displayedExercise?.id)
        } else {
            RemoteImageView(url: viewModel.displayedExercise?.imageUrl)
        }
    }

    private var getReadyBody: some View {
        VStack(spacing: Layout.Spacing.s) {
            Text("\(viewModel.remainingSeconds)")
                .font(.system(size: 40, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Asset.Color.mainColor.color)

            Text("Get ready!")
                .font(Typography.headlineSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)

            exerciseNameRow

            skipButton
                .padding(.top, Layout.Spacing.s)
        }
        .frame(maxWidth: .infinity)
    }

    private var skipButton: some View {
        Button("Skip", action: viewModel.skip)
            .font(Typography.bodyLarge)
            .foregroundStyle(Asset.Color.white.color)
            .frame(width: 168, height: 46)
            .background(Asset.Color.mainColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var exerciseBody: some View {
        VStack(spacing: Layout.Spacing.s) {
            Text(viewModel.timerLabel)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Asset.Color.mainColor.color)

            exerciseNameRow

            transportControls
                .padding(.top, Layout.Spacing.s)

            Text(viewModel.positionLabel)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }
        .frame(maxWidth: .infinity)
    }

    private var restBody: some View {
        VStack(spacing: Layout.Spacing.s) {
            HStack {
                Text(viewModel.nextPositionLabel)
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                Spacer()
                nameWithInfo(viewModel.nextExercise?.name ?? "")
            }

            Text("Rest")
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .padding(.top, Layout.Spacing.s)

            Text(viewModel.timerLabel)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Self.accent)

            Button("Skip", action: viewModel.skip)
                .font(Typography.labelMedium)
                .foregroundStyle(Asset.Color.white.color)
                .padding(.horizontal, Layout.Spacing.xl)
                .padding(.vertical, Layout.Spacing.s)
                .background(Asset.Color.mainColor.color)
                .clipShape(Capsule())
                .padding(.top, Layout.Spacing.s)
        }
        .frame(maxWidth: .infinity)
    }

    private var exerciseNameRow: some View {
        nameWithInfo(viewModel.currentExercise?.name ?? "")
    }

    private func nameWithInfo(_ name: String) -> some View {
        HStack(spacing: Layout.Spacing.xs) {
            Text(name)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .lineLimit(1)

            Button(action: viewModel.showInstructions) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }
        }
    }

    // MARK: - Transport

    private var transportControls: some View {
        HStack(spacing: Layout.Spacing.s) {
            transportButton(symbol: "backward.end.fill", filled: true, action: viewModel.previousExercise)
                .disabled(viewModel.index == 0)
                .opacity(viewModel.index == 0 ? 0.4 : 1)

            // Pause is de-emphasised while running; once stopped the play button takes the accent,
            // so the action the user most likely wants next reads first.
            transportButton(
                symbol: viewModel.isPaused ? "play.fill" : "pause.fill",
                filled: viewModel.isPaused,
                wide: true,
                action: viewModel.togglePause
            )

            transportButton(symbol: "forward.end.fill", filled: true, action: viewModel.nextExerciseTapped)
        }
    }

    private func transportButton(symbol: String,
                                 filled: Bool,
                                 wide: Bool = false,
                                 action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Asset.Color.white.color)
                .frame(width: wide ? 64 : 52, height: 44)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium, style: .continuous))
        }
    }

    // MARK: - Pause options

    private var pauseOptions: some View {
        VStack(spacing: Layout.Spacing.m) {
            Spacer()

            Text("💪")
                .font(.system(size: 64))

            Text("You're doing great")
                .font(Typography.headlineSmall)
                .foregroundStyle(Self.accent)

            Text("Want to keep going, take a short break, or continue later?")
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Layout.Spacing.l)

            Button("Keep exercising", action: viewModel.resume)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.m)
                .background(Asset.Color.mainColor.color)
                .clipShape(Capsule())
                .padding(.top, Layout.Spacing.s)

            Button("Restart this exercise", action: viewModel.restartCurrentExercise)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.mainColor.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.m)
                .overlay(Capsule().stroke(Asset.Color.mainColor.color, lineWidth: 1.5))

            Button("Do it later", action: viewModel.doItLater)
                .font(Typography.labelMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .underline()

            Spacer()

            PreloadedNativeAdsView(adKey: .practiceCompact,
                                   style: .contentCard,
                                   height: NativeAdViewStyle.contentCard.height)
        }
        .padding(Layout.Spacing.m)
    }

    // MARK: - Completed

    private var completed: some View {
        VStack(spacing: Layout.Spacing.m) {
            Spacer()

            LottieView(animation: .named("Trophy_Confetti.json"))
                .looping()
                .frame(width: 200, height: 200)

            Text("All Done!")
                .font(FontFamily.Inter.bold.font(size: 26))
                .foregroundStyle(Self.accent)

            Text("You've completed all your workouts today. Your body is getting stronger keep it up!")
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Layout.Spacing.l)

            Button("Finish", action: viewModel.exit)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.m)
                .background(Asset.Color.mainColor.color)
                .clipShape(Capsule())
                .padding(.top, Layout.Spacing.s)

            Spacer()

            PreloadedNativeAdsView(adKey: .practiceCompact,
                                   style: .contentCard,
                                   height: NativeAdViewStyle.contentCard.height)
        }
        .padding(Layout.Spacing.m)
    }
}


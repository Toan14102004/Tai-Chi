//
//  ProgressStreakView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

struct ProgressStreakView: View {
    @StateObject private var viewModel = ViewModel()

    private static let weekdaySymbols = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: "Your Streak", back: viewModel.back)

            ScrollView {
                VStack(spacing: Layout.Spacing.l) {
                    Asset.Icon.Commo.yourStreak.image
                        .toIcon(110.iPad(120))

                    Text("\(viewModel.streakDays)-Day Streak !")
                        .font(Typography.headlineLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    Text("Every check-in moves your forward. Keep coming back and let your streak grow.")
                        .multilineTextAlignment(.center)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else {
                        calendar
                    }
                }
                .padding(Layout.Spacing.m)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // `2168:5690`'s frame fill: a top-to-bottom gradient fading from coral through peach
            // into the app's own cream, rather than a flat background like every other screen.
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#FE7E7A"), location: 0),
                    .init(color: Color(hex: "#FFCBA6"), location: 0.21),
                    .init(color: Asset.Color.bgPrimary.color, location: 0.41),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("progressStreakVC")
    }

    private var calendar: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(Self.monthFormatter.string(from: viewModel.month))
                    .font(Typography.headlineSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Layout.Spacing.s) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(Typography.labelSmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                ForEach(viewModel.gridDays, id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func dayCell(_ day: Date) -> some View {
        let isActive = viewModel.isActive(day)
        let isInMonth = viewModel.isInDisplayedMonth(day)

        return Text(Self.dayFormatter.string(from: day))
            .font(Typography.bodySmall)
            .foregroundStyle(isActive ? Asset.Color.white.color
                             : isInMonth ? Asset.Color.textPrimary.color : Asset.Color.textTertiary.color)
            .frame(width: 32, height: 32)
            .background(isActive ? Asset.Color.mainColor.color : Color.clear, in: Circle())
            .frame(maxWidth: .infinity)
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}

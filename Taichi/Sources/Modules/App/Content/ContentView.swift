//
//  ContentView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/9/25.
//

import SwiftUI

enum Tab: CaseIterable {
    case practice, discover, progress, profile

    var title: String {
        switch self {
        case .practice: "TaiChi"
        case .discover: "Discover"
        case .progress: "Progress"
        case .profile: "Profile"
        }
    }

    /// Short label for the tab bar item — `title` is the full header text ("TaiChi"),
    /// which is too long to sit under a tab bar icon next to "Discover"/"Progress"/"Profile".
    var tabLabel: String {
        switch self {
        case .practice: "Plan"
        case .discover: "Discover"
        case .progress: "Progress"
        case .profile: "Profile"
        }
    }

    var normalIcon: ImageAsset {
        switch self {
        case .practice: Asset.Icon.TabBar.Normal.planNormal
        case .discover: Asset.Icon.TabBar.Normal.discoverNormal
        case .progress: Asset.Icon.TabBar.Normal.progressNormal
        case .profile: Asset.Icon.TabBar.Normal.profileNormal
        }
    }

    var selectedIcon: ImageAsset {
        switch self {
        case .practice: Asset.Icon.TabBar.Selected.planSelected
        case .discover: Asset.Icon.TabBar.Selected.discoverSelected
        case .progress: Asset.Icon.TabBar.Selected.progressSelected
        case .profile: Asset.Icon.TabBar.Selected.profileSelected
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = ViewModel()
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State var currentTab: Tab = .practice

    var body: some View {
        if networkMonitor.isConnected {
            mainContent
        } else {
            NoInternetView()
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .top) {
            Asset.Color.bgPrimary.color
                .ignoresSafeArea()

            if currentTab == .profile {
                LinearGradient(
                    colors: [
                        Color(hex: "#D6D9FF"),
                        Color(hex: "#F4EAFE"),
                        Asset.Color.bgPrimary.color
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height / 3)
                .ignoresSafeArea(edges: .top)
            }


            VStack(spacing: 0) {
            if currentTab != .profile {
                header()
            }

            TabView(selection: $currentTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Group {
                        switch tab {
case .practice:
                            PracticeHomeView()
                        case .discover:
                            DiscoverHomeView()
                        case .progress:
                            ProgressHomeView()
                        case .profile:
                            ProfileView()
                        default:
                            // TODO: replace with real screens as each flow lands (see 7-day sprint plan).
                            placeholderContent(for: tab)
                        }
                    }
                    .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            tabBar()
        }
        .navigationBarBackButtonHidden(true)
        .flowDestination(for: Coordinator.Navigation.self) { item in
            switch item {
            case .settingView:
                SettingView(viewModel: .init())
            case .languageView:
                LanguageView(viewModel: .init())
case let .workoutSchedule(programId):
                WorkoutScheduleView(programId: programId)
            case let .workoutDay(workoutId):
                WorkoutDayView(workoutId: workoutId)
            case let .exerciseDetail(workoutId, exerciseId):
                ExerciseDetailView(workoutId: workoutId, initialExerciseId: exerciseId)
            case let .workoutSession(workoutId):
                WorkoutSessionView(workoutId: workoutId)
            case let .dailyRoutine(routineId, title):
                DailyRoutineView(routineId: routineId, title: title)
            case let .discoverCategory(category, title):
                DiscoverCategoryView(category: category, title: title)
            case let .discoverWorkout(workoutId):
                DiscoverWorkoutView(workoutId: workoutId)
            case .progressActivityType:
                ProgressActivityTypeView()
            case let .progressActivityForm(categoryId, categoryName, iconKey, met, existingActivityId, initialDurationSeconds, initialCalories):
                ProgressActivityFormView(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    iconKey: iconKey,
                    met: met,
                    existingActivityId: existingActivityId,
                    initialDurationSeconds: initialDurationSeconds,
                    initialCalories: initialCalories
                )
            case .progressStreak:
                ProgressStreakView()
        case .personalDetails:
                PersonalDetailsView()
            case .workoutSettings:
                WorkoutSettingsView()
            case .reminder:
                ReminderView()
            }
        }
        .popup(item: $viewModel.coordinator.alert) { item in
            switch item {
            case .error(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: .red,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: {
                        viewModel.coordinator.alert = nil
                    }
                )
            case .success(let title, let message):
                CustomAlertView(
                    title: LocalizedStringKey(title),
                    titleColor: .green,
                    description: LocalizedStringKey(message),
                    primaryActionTitle: "OK",
                    primaryAction: {
                        viewModel.coordinator.alert = nil
                    }
                )
            }
        } customize: { params in
            params.centerPopup()
        }
    }

    @ViewBuilder
    func header() -> some View {
        HStack(spacing: Layout.Spacing.s) {
            Text(currentTab.title.localizedKey)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .font(Typography.headlineSmall)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !subscriptionManager.isSubscribed {
                Button {
                    viewModel.showPremiumFullScreen()
                } label: {
                    premiumCrown
                }
            }
        }
        .frame(height: 64)
        .padding(.horizontal, Layout.Spacing.m)
        .frame(maxWidth: .infinity)
        .background(Asset.Color.bgPrimary.color)
    }

    /// The header crown (Figma `vip 1`): the crown silhouette filled with the design's yellow-to-orange
    /// gradient. The bundled PNG still carries the old purple-to-yellow colouring, so only its shape
    /// is used.
    private var premiumCrown: some View {
        LinearGradient(
            colors: [Color(hex: "#FFDE00"), Color(hex: "#FD5900")],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 24, height: 24)
        .mask {
            Asset.Icon.Commo.premium.image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    @ViewBuilder
    func placeholderContent(for tab: Tab) -> some View {
        VStack(spacing: Layout.Spacing.s) {
            Spacer()
            tab.normalIcon.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundStyle(Asset.Color.textBrandPrimary.color)
            Text("\(tab.title) screen")
                .font(FontFamily.Inter.bold.font(size: Layout.Text.title3))
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text("Build this screen based on the Figma design.")
                .font(FontFamily.Inter.regular.font(size: Layout.Text.callout))
                .foregroundStyle(Asset.Color.textTertiary.color)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, Layout.Spacing.xxl * 2)
    }

    @ViewBuilder
    func tabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    currentTab = tab
                } label: {
                    VStack(spacing: 4) {
                        // Template so the icon takes the label colour below: the PNGs are pre-tinted
                        // with the old coral.
                        (currentTab == tab ? tab.selectedIcon : tab.normalIcon).image
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text(tab.tabLabel.localizedKey)
                            .font(Typography.captionMedium)
                    }
                    .foregroundStyle(
                        currentTab == tab
                            ? Asset.Color.textBrandPrimary.color
                            : Asset.Color.textTertiary.color
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 10)
        .background(
            Asset.Color.white.color
                // Figma `button/nav bar`: drop shadow #000 8 %, y -1, blur 20.
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -1)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ContentView()
        .preview()
}

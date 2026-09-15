//
//  RootView.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Combine
import Foundation
import SwiftUI

struct RootView: View {
    @Injected var subscriptionManager: SubscriptionManager
    @Injected var adsManager: AdsManager
    @Injected var localStorageService: LocalStorageService
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var loadingService: LoadingService
    @Environment(\.injected) private var injected: DIContainer
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var languageManager = LanguageManager.shared

    var body: some View {
        ZStack {
            FlowStack($viewModel.path, withNavigation: true) {
                SplashView()
                    .modifier(NavigatorModifier())
                    .flowDestination(for: Coordinator.Navigation.self) { item in
                        switch item {
                        case .welcome: WelcomeView(viewModel: .init())
                        case .language: LanguageView(viewModel: .init(isOnboardingContext: true))
                        case .onboarding: OnboardingView(viewModel: .init())
                        case .profileSetup: ProfileSetupView(viewModel: .init())
                        case .content: ContentView()
                        }
                    }
                    .flowDestination(for: Coordinator.FullScreen.self) { item in
                        switch item {
                        case let .subscription(subscriptionEntryPoint):
                            SubscriptionView(subscriptionEntryPoint: subscriptionEntryPoint)
                        case let .exerciseInstructions(title, imageUrl, howTo, commonMistakes, breathingTips, guidance):
                            InstructionsSheet(
                                title: title,
                                imageUrl: imageUrl,
                                howTo: howTo,
                                commonMistakes: commonMistakes,
                                breathingTips: breathingTips,
                                guidance: guidance
                            )
                        }
                    }
            }
            .environmentObject(subscriptionManager)
            .environment(\.locale, languageManager.currentLocale)
            
            if loadingService.isLoading {
                VStack {
                    ActivityIndicatorView(
                        isVisible: $loadingService.isLoading,
                        type: loadingService.indicatorType
                    )
                    .foregroundColor(loadingService.indicatorColor)
                    .frame(
                        width: Layout.Spacing.xxl,
                        height: Layout.Spacing.xxl
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.3))
            }
        }
    }
}

#Preview(body: {
    ContentView()
        .preview()
})

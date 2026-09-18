//
//  SplashView.swift
//  MapTracking
//
//  Created by Toan Nguyen on 17/4/25.
//

import SwiftUI
import AppTrackingTransparency

struct SplashView: View {
    @Navigation var navigator
    
    @Injected var localStorageService: LocalStorageService
    @Injected var adsManager: AdsManager
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var loadingProgress: CGFloat = 0.0
    @State private var didShowAds: Bool = false
    @State private var hasNavigated: Bool = false
    
    @State private var isRemoteConfigReady: Bool = false
    @State private var didRequestAppTracking: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .center, spacing: Layout.Spacing.m) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "D9D9D9"))
                    .frame(width: 80, height: 80)

                Text("Find calm, balance, and strength every day.")
                    .font(FontFamily.Inter.medium.font(size: 16))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Layout.Spacing.m)

            Spacer()

            VStack(spacing: 20) {
                Text("This action can contain ads")
                    .font(FontFamily.Inter.medium.font(size: 16))
                    .foregroundStyle(Asset.Color.white.color)

                GeometryReader { proxy in
                    let width = proxy.size.width
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "F7F7F7"))
                            .frame(height: 8)

                        Capsule()
                            .fill(Asset.Color.mainColor.color)
                            .frame(width: width * max(0, min(1, loadingProgress)), height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, Layout.Spacing.xl)

            }
            .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Asset.Image.splashBg.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.2))
                .ignoresSafeArea()
        }
        .trackScreen("splashVC")
        .onAppear {
            withAnimation(.easeInOut(duration: 5)) {
                loadingProgress = 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                requestAppTracking { _ in
                    didRequestAppTracking = true
                    handlePushNext()
                }
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: .appConfigReady)) { _ in
            isRemoteConfigReady = true
            handlePushNext()
        }
        .onChange(of: subscriptionManager.isLoading) { isLoading in
            if !isLoading {
                handlePushNext()
            }
        }
    }
}

// MARK: Func
private extension SplashView {
    
    func requestAppTracking(completion: ((Bool) -> Void)? = nil) {
        ATTrackingManager.requestTrackingAuthorization { status in
            let authorized = (status == .authorized)
            DispatchQueue.main.async {
                completion?(authorized)
            }
        }
    }
    
    func handlePushNext() {
        guard didRequestAppTracking && isRemoteConfigReady && !subscriptionManager.isLoading && !hasNavigated else { return }

        // Plans only load for a user the server knows, so an install that never finished
        // Profile Setup -- including one set up against the old Pilates API -- starts over.
        guard !localStorageService.isDeviceRegistered else {
            if localStorageService.isDisplayPremiumAfterSplash && !subscriptionManager.isSubscribed {
                showSplashInter {
                    DispatchQueue.main.async {
                        navigator.push(RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .onboardingSecond))
                    }
                }
            } else {
                showSplashInter {
                    DispatchQueue.main.async {
                        navigator.push(RootView.Coordinator.Navigation.content)
                    }
                }
            }
            hasNavigated = true
            return
        }
        
        showSplashInter {
            navigator.push(RootView.Coordinator.Navigation.welcome)
        }
        hasNavigated = true
    }
    
    func showSplashInter(action: @escaping () -> Void) {
        let adPlacement = localStorageService.splashInterAd
        let adPlacementHight = localStorageService.splashInterAdHigh
        adsManager.showSplashInterstitial(
            adPlacement: adPlacement,
            adPlacementHigh: adPlacementHight,
            onDismissed: {
                action()
            },
            onFailed: { _ in
                action()
            })
    }
}

#Preview {
    SplashView()
        .preview()
}

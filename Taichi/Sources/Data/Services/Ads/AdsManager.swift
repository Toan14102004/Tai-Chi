//
//  AdsManager.swift
//  ARDraw
//
//  Created by Toan Nguyen on 5/9/25.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdsManager: NSObject, ObservableObject, Service {
    
    @Injected var localStorageService: LocalStorageService
    
    var interstialAdService = InterstitialAdService()
    var rewardedAdService = RewardedAdService()
    var appOpenAdService = AppOpenAdService()
    var bannerAdService = BannerAdService()

    @Published var isShowingInterAds: Bool = false
    @Published var suppressNextAppOpenAd: Bool = false
    @Published var suppressNextSplashInterstitial: Bool = true
    
    var lastTimeShowSameAds: Int64 = 0
    var lastTimeShowOtherAds: Int64 = 0
    
    var shouldAutostart: Bool = true
    
    func start() {
//        interstialAdService.countShowInter = localStorageService.distanceCountShowInterShare
    }
    
    func stop() {
    }
    
    func suppressAppOpenAdOnce() {
        suppressNextAppOpenAd = true
    }
    
    // MARK: - Interstitial Ad

    @MainActor
    func loadInterstitialAds(
        adPlacement: AdPlacement,
        adPlacementHigh: AdPlacement? = nil,
        onLoadInterstitialSuccess: (() -> Void)? = nil
    ) {
        print("[AdsManager] loadInterstitialAds called: adUnitId=\(adPlacement.id)")
        interstialAdService.onLoadSuccess = {
            onLoadInterstitialSuccess?()
        }

        interstialAdService.load(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
    }

    @MainActor
    func showInterstitialAd(
        adPlacement: AdPlacement,
        adPlacementHigh: AdPlacement? = nil,
        onDismissed: (() -> Void)? = nil,
        onFailed: ((Error) -> Void)? = nil,
        onShown: (() -> Void)? = nil
    ) {
        print("[AdsManager] showInterstitialAd called: adUnitId=\(adPlacement.id)")
        interstialAdService.onDismissed = {
            self.isShowingInterAds = false
//            self.lastTimeShowOtherAds = Int64(Date().timeIntervalSince1970 * 1000)
            self.lastTimeShowSameAds = Int64(Date().timeIntervalSince1970 * 1000)
            onDismissed?()
        }

        interstialAdService.onFailed = { error in
            onFailed?(error)
        }

        interstialAdService.onShown = {
            onShown?()
            self.loadInterstitialAds(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
        }
        
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        let minIntervalOtherAdsMs = Int64(localStorageService.distanceTimeShowOtherAds) * 1000
        let hasEnoughTimeForOtherAds = lastTimeShowOtherAds == 0 || (currentTime - lastTimeShowOtherAds) >= minIntervalOtherAdsMs
        
        let minIntervalSameAdsMs = Int64(localStorageService.distanceTimeShowSameAds) * 1000
        let hasEnoughTimeForSameAds = lastTimeShowSameAds == 0 || (currentTime - lastTimeShowSameAds) >= minIntervalSameAdsMs
        
        let threshold = localStorageService.distanceCountShowInterShare
        let isCountSatisfied = interstialAdService.countShowInter >= threshold
        
        if hasEnoughTimeForOtherAds && (hasEnoughTimeForSameAds || isCountSatisfied) {
            isShowingInterAds = true
            interstialAdService.show(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
        } else {
            interstialAdService.countShowInter += 1
            onDismissed?()
        }
    }

    // MARK: - Splash Interstitial (bypasses gating)

    @MainActor
    func showSplashInterstitial(
        adPlacement: AdPlacement,
        adPlacementHigh: AdPlacement? = nil,
        onDismissed: (() -> Void)? = nil,
        onFailed: ((Error) -> Void)? = nil,
        onShown: (() -> Void)? = nil
    ) {
        print("[AdsManager] showSplashInterstitial called: adUnitId=\(adPlacement.id)")
        interstialAdService.onDismissed = {
            self.lastTimeShowSameAds = Int64(Date().timeIntervalSince1970 * 1000)
            self.isShowingInterAds = false
            onDismissed?()
        }

        interstialAdService.onFailed = { error in
            self.isShowingInterAds = false
            onFailed?(error)
        }

        interstialAdService.onShown = {
            onShown?()
        }
        isShowingInterAds = true
        interstialAdService.showSplashInterstitial(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
    }

    @MainActor
    func suppressSplashInterstitialOnce() {
        suppressNextSplashInterstitial = true
    }

    // MARK: - Rewarded Ad

    @MainActor
    func loadRewardedAd(adPlacement: AdPlacement) {
        rewardedAdService.load(adPlacement: adPlacement, adPlacementHigh: nil)
    }

    @MainActor
    func showRewardedAd(
        adPlacement: AdPlacement,
        adPlacementHigh: AdPlacement?,
        onReward: @escaping (AdReward) -> Void
    ) {
        rewardedAdService.show(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh, onReward: { reward in
            self.lastTimeShowOtherAds = Int64(Date().timeIntervalSince1970 * 1000)
            onReward(reward)
        })
    }

    // MARK: - App Open Ad

    @MainActor
    func loadAppOpenAd(adPlacement: AdPlacement, adPlacementHight: AdPlacement?) {
        guard !isShowingInterAds else { return }
        appOpenAdService.load(adPlacement: adPlacement, adPlacementHigh: adPlacementHight)
    }

    @MainActor
    func showAppOpenAd(adPlacement: AdPlacement, adPlacementHight: AdPlacement?, onDismissed: (() -> Void)? = nil) {
        guard !isShowingInterAds else {
            onDismissed?()
            return
        }
        if suppressNextAppOpenAd {
            suppressNextAppOpenAd = false
            onDismissed?()
            return
        }
        
        let handler = { [weak self] in
            onDismissed?()
            self?.lastTimeShowOtherAds = Int64(Date().timeIntervalSince1970 * 1000)
        }
        
        appOpenAdService.show(adPlacement: adPlacement, adPlacementHigh: adPlacementHight, onDismissed: handler)
    }
    
    // MARK: - Mediation Debugger
    
    @MainActor
    func presentMediationDebugger() {
        guard let rootViewController = topMostViewController() else {
            print("[AdsManager] Failed to present mediation debugger: No root view controller found")
            return
        }
        MobileAds.shared.presentAdInspector(from: rootViewController) { error in
            print(error)
        }
    }
    
    private func topMostViewController() -> UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
            let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }

        var current = topController
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }
}

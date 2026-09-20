//
//  InterstitialAdService.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation
import UIKit
import GoogleMobileAds

final class InterstitialAdService: NSObject, AdService {
    @Injected var localStorageService: LocalStorageService
    @Injected var keychainStorage: KeychainStorage
    @Injected var subscriptionManager: SubscriptionManager
    @Injected var adsManager: AdsManager

    private(set) var interstitialAd: InterstitialAd?
    private(set) var splashInterstitialAd: InterstitialAd?

    var onDismissed: (() -> Void)?
    var onFailed: ((Error) -> Void)?
    var onShown: (() -> Void)?
    var onLoadSuccess: (() -> Void)?

    private let events = AdsEventManager.shared

    var countShowInter: Int = 1
    private let loadTimeout: TimeInterval = 20
    
    private var retryAttempt = 0
    private var isLoading = false
    private var isShowSplashInter = false
    
    // Store last placements for auto-reload
    private var lastAdPlacement: AdPlacementRepresentable?
    private var lastAdPlacementHigh: AdPlacementRepresentable?

    // MARK: - AdService
    @MainActor
    func canShow(adPlacement: AdPlacementRepresentable) -> Bool {
        guard AppFlags.adsEnabled else { return false }
        guard adPlacement.isEnabled else { return false }
        guard !subscriptionManager.hidesAds else { return false }
        return true
    }

    @MainActor
    func load(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?) {
        self.lastAdPlacement = adPlacement
        self.lastAdPlacementHigh = adPlacementHigh
        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        
        guard canShow(adPlacement: primary) else {
            onLoadSuccess?()
            return
        }
        
        guard interstitialAd == nil else {
            onLoadSuccess?()
            return
        }
        
        guard !isLoading else { return }
        isLoading = true

        let request = Request()
        
        print("[InterstitialAdService] Start loading ad: \(primary.id)")
        
        // Timeout for this specific attempt (optional, but good practice if GAD hangs)
        // However, we rely on GAD callback mostly.
        // We will just use the simple load
        
        InterstitialAd.load(with: primary.id, request: request) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false
            
            if let error {
                print("[InterstitialAdService] Failed to load interstitial ad (\(primary.id)): \(error.localizedDescription)")
                
                // Try fallback if available and we are currently trying primary (high)
                if primary.id == adPlacementHigh?.id, let low = adPlacement as? AdPlacement {
                     print("[InterstitialAdService] Trying fallback...")
                     self.load(adPlacement: low, adPlacementHigh: nil)
                     return
                }
                
                // If we are here, it means both primary (or fallback) failed.
                // Schedule Retry
                self.scheduleRetry(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
                return
            }
            
            print("[InterstitialAdService] Ad loaded successfully")
            self.retryAttempt = 0 // Reset retry count on success
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.onLoadSuccess?()
            
            self.interstitialAd?.paidEventHandler = { adValue in
                let adapterName =
                self.interstitialAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: self.interstitialAd?.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .interstitial,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: "USD",
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }
        }
    }
    
    private func scheduleRetry(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?) {
//        let delay = pow(2.0, Double(min(5, retryAttempt)))
        let delay = 1.0
        retryAttempt += 1
        print("[InterstitialAdService] Load failed. Retrying in \(delay)s (Attempt \(retryAttempt))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            // Check again if we need to load (maybe loaded in between?)
            guard let self = self, self.interstitialAd == nil else { return }
            self.load(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
        }
    }
    
    @MainActor
    func show(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?) {
        guard AppFlags.adsEnabled else { onDismissed?(); return }
        guard !subscriptionManager.hidesAds else { onDismissed?(); return }

        // Check if ad is ready
        if let interstitialAd, let rootVC = topMostViewController() {
            interstitialAd.present(from: rootVC)
        } else {
            // Ad NOT ready
            print("[InterstitialAdService] Ad not ready. Skipping...")
            countShowInter += 1
            
            // Trigger load for next time
            load(adPlacement: adPlacement, adPlacementHigh: adPlacementHigh)
            
            // Proceed immediately
            onDismissed?()
        }
    }

    // MARK: - Splash Interstitial (bypasses gating)
    @MainActor
    func showSplashInterstitial(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?) {
        guard AppFlags.adsEnabled else { onDismissed?(); return }
        guard localStorageService.isDisplayPremiumAfterSplash else { onDismissed?(); return }
        guard !subscriptionManager.hidesAds else { onDismissed?(); return }

        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        guard primary.isEnabled else {
            if let fallback = (adPlacementHigh?.isEnabled == true) ? adPlacement : nil {
                showSplashInterstitial(adPlacement: fallback, adPlacementHigh: nil)
            } else {
                onDismissed?()
            }
            return
        }

        let request = Request()
        var didFinishShowSplash = false
        let timeoutShowSplash = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard didFinishShowSplash == false else { return }
            didFinishShowSplash = true
            if let fallback = (adPlacementHigh?.isEnabled == true) ? adPlacement : nil {
                self.showSplashInterstitial(adPlacement: fallback, adPlacementHigh: nil)
            } else {
                self.onFailed?(NSError(domain: "ads.timeout", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Splash interstitial load timeout"]))
                self.onDismissed?()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + loadTimeout, execute: timeoutShowSplash)
        InterstitialAd.load(with: primary.id, request: request) { [weak self] ad, error in
            guard let self else { return }
            guard didFinishShowSplash == false else { return }
            didFinishShowSplash = true
            timeoutShowSplash.cancel()
            if let error {
                print("Failed to load splash interstitial ad (\(primary.id)): \(error.localizedDescription)")
                if let fallback = (adPlacementHigh?.isEnabled == true) ? adPlacement : nil {
                    self.showSplashInterstitial(adPlacement: fallback, adPlacementHigh: nil)
                } else {
                    self.onFailed?(error)
                    self.onDismissed?()
                }
                return
            }

            self.splashInterstitialAd = ad
            self.splashInterstitialAd?.fullScreenContentDelegate = self
            
            self.splashInterstitialAd?.paidEventHandler = { adValue in
                let adapterName = self.splashInterstitialAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: self.splashInterstitialAd?.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .interstitial,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: "USD",
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }

            if let rootVC = topMostViewController() {
                isShowSplashInter = true
                self.splashInterstitialAd?.present(from: rootVC)
            }
        }
    }
    
    func topMostViewController() -> UIViewController? {
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

extension InterstitialAdService: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard ad is InterstitialAd else { return }
        onShown?()
        // Successful show -> reset counter
        if !isShowSplashInter {
            countShowInter = 1
        }
        isShowSplashInter = false
    }

    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard ad is InterstitialAd else { return }
        // Check if it's splash interstitial or regular interstitial
        if ad === splashInterstitialAd {
            splashInterstitialAd = nil
        } else {
            interstitialAd = nil
            // Reload immediately after dismiss
            if let lastAdPlacement {
                print("[InterstitialAdService] Auto reloading ad after dismiss...")
                load(adPlacement: lastAdPlacement, adPlacementHigh: lastAdPlacementHigh)
            }
        }
        onDismissed?()
        onDismissed = nil
        onFailed = nil
        onShown = nil
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        guard ad is InterstitialAd else { return }
        // Check if it's splash interstitial or regular interstitial
        if ad === splashInterstitialAd {
            splashInterstitialAd = nil
        } else {
            interstitialAd = nil
            // Present failed -> increment counter so we can try again later (only for regular inter)
             // countShowInter += 1 // actually if it failed to present, maybe we should not reset interval?
             // Flowchart says "Fail -> Reload".
             // We should reload.
        }
        onFailed?(error)
        onDismissed = nil
        onFailed = nil
        onShown = nil
    }
    
    
    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        if let interstitial = ad as? InterstitialAd {
            let payload = ClickPayload(
                adUnitId: interstitial.adUnitID,
                adKind: .interstitial,
                timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
            )
            AdsEventManager.shared.logClick(payload)
        }
    }
}

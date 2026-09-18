//
//  AppOpenAdService.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation
import GoogleMobileAds
import UIKit

final class AppOpenAdService: NSObject, AdService {
    @Injected var keychainStorage: KeychainStorage
    @Injected var subscriptionManager: SubscriptionManager
    @Injected var localStorageService: LocalStorageService
    @Injected var adsManager: AdsManager

    private(set) var appOpenAd: AppOpenAd?
    private var isShowingAppOpenAd = false
    private var firstTimeShowOpenAd = false
    private var loadTime: Date?
    private var lastTimeShowAppOpen: Int64 = 0
    private let events = AdsEventManager.shared
    
    var onDismissed: (() -> Void)?

    // MARK: - AdService

    @MainActor
    func canShow(adPlacement: AdPlacementRepresentable) -> Bool {
        guard AppFlags.adsEnabled else { return false }
        guard !localStorageService.isFirstTimeOpenApp else { return false }
        guard !isShowingAppOpenAd else { return false }
        guard firstTimeShowOpenAd else { firstTimeShowOpenAd = true; return false }
        guard adPlacement.isEnabled else { return false }
        guard !subscriptionManager.hidesAds else { return false }
        
        return true
    }

    @MainActor
    func load(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?) {
        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        print("[AppOpenAd] Load requested for \(primary.id)")
        
        guard appOpenAd == nil else {
            print("[AppOpenAd] Load: Ad already loaded")
            return
        }
        
        print("[AppOpenAd] Loading ad with ID: \(primary.id)")
        let request = Request()
        AppOpenAd.load(with: primary.id, request: request) { [weak self] ad, error in
            guard let self else { return }
            if let error {
                print("[AppOpenAd] Failed to load ad for \(primary.id): \(error.localizedDescription)")
                return
            }
            print("[AppOpenAd] Ad loaded successfully for \(primary.id)")
            appOpenAd = ad
            appOpenAd?.fullScreenContentDelegate = self
            loadTime = Date()

            appOpenAd?.paidEventHandler = { [weak self] adValue in
                let adapterName = self?.appOpenAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: self?.appOpenAd?.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .appOpen,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: "USD",
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }
        }
    }

    @MainActor
    func show(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?, onDismissed: (() -> Void)? = nil) {
        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        print("[AppOpenAd] Show requested for \(primary.id)")
        
        self.onDismissed = onDismissed
        
        guard canShow(adPlacement: primary) else {
            print("[AppOpenAd] Show: canShow returned false")
            self.onDismissed?()
            return
        }
        if let appOpenAd,
           let rootVC = UIApplication.shared.connectedScenes.first.flatMap({ $0 as? UIWindowScene })?.windows.first?
           .rootViewController {
            print("[AppOpenAd] Presenting existing loaded ad")
            appOpenAd.present(from: rootVC)
        } else {
            print("[AppOpenAd] Ad not ready or no rootVC, attempting on-demand load")
            let request = Request()
            AppOpenAd.load(with: primary.id, request: request) { [weak self] ad, error in
                guard let self else { return }
                if let error {
                    print("[AppOpenAd] On-demand load failed for \(primary.id): \(error.localizedDescription)")
                    // Is this recursive call intended? It calls load() which is usually for preloading.
                    // Assuming intention is to preload for next time if this show fails.
                    load(adPlacement: primary, adPlacementHigh: nil)
                    self.onDismissed?()
                    return
                }

                print("[AppOpenAd] On-demand load success for \(primary.id)")
                appOpenAd = ad
                appOpenAd?.fullScreenContentDelegate = self
                loadTime = Date()

                appOpenAd?.paidEventHandler = { [weak self] adValue in
                    let adapterName = self?.appOpenAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                    let payload = PaidImpressionPayload(
                        adUnitId: self?.appOpenAd?.adUnitID ?? "",
                        mediationAdapterClassName: adapterName,
                        adKind: .appOpen,
                        revenueMicros: adValue.value.doubleValue,
                        precision: adValue.precision.rawValue,
                        currencyCode: "USD",
                        timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                    )
                    AdsEventManager.shared.logPaidAdImpression(payload)
                }

                if let rootVC = UIApplication.shared.connectedScenes.first.flatMap({ $0 as? UIWindowScene })?.windows
                    .first?.rootViewController {
                    print("[AppOpenAd] Presenting on-demand loaded ad")
                    ad?.present(from: rootVC)
                } else {
                    print("[AppOpenAd] Still no rootVC to present on-demand ad")
                    self.onDismissed?()
                }
            }
            // Why call load again here? It seems redundant if we just called AppOpenAd.load above.
            // Leaving as is to preserve logic, just adding log.
            print("[AppOpenAd] Triggering precautionary preload")
            load(adPlacement: primary, adPlacementHigh: nil)
        }
    }
}

extension AppOpenAdService: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard ad is AppOpenAd else { return }
        print("[AppOpenAd] Delegate: adWillPresentFullScreenContent")
        isShowingAppOpenAd = true
    }

    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard ad is AppOpenAd else { return }
        print("[AppOpenAd] Delegate: adDidDismissFullScreenContent")
        isShowingAppOpenAd = false

        // Clear the ad instance
        if ad === appOpenAd {
            print("[AppOpenAd] Clearing current ad instance")
            appOpenAd = nil
        }

        onDismissed?()
        lastTimeShowAppOpen = Int64(Date().timeIntervalSince1970 * 1000)
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        guard ad is AppOpenAd else { return }
        print("[AppOpenAd] Delegate: didFailToPresentFullScreenContentWithError: \(error.localizedDescription)")
        isShowingAppOpenAd = false

        // Clear the ad instance
        if ad === appOpenAd {
            appOpenAd = nil
        }
    }

    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        if let appOpenAd = ad as? AppOpenAd {
            print("[AppOpenAd] Delegate: adDidRecordClick")
            let payload = ClickPayload(
                adUnitId: appOpenAd.adUnitID,
                adKind: .appOpen,
                timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
            )
            AdsEventManager.shared.logClick(payload)
        }
    }
}

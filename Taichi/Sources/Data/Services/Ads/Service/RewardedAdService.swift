//
//  RewardedAdService.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation
import GoogleMobileAds
import UIKit

final class RewardedAdService: NSObject, AdService {
    @Injected var keychainStorage: KeychainStorage
    @Injected var subscriptionManager: SubscriptionManager

    private(set) var rewardedAd: RewardedAd?
    private let events = AdsEventManager.shared

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
        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        guard canShow(adPlacement: primary) else { return }
        guard rewardedAd == nil else { return }
        let request = Request()
        RewardedAd.load(with: primary.id, request: request) { [weak self] ad, error in
            if let error {
                print("Failed to load rewarded ad for \(primary.id): \(error.localizedDescription)")
                if let low = (adPlacementHigh?.isEnabled == true) ? adPlacement : nil {
                    self?.load(adPlacement: low, adPlacementHigh: nil)
                }
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self

            self?.rewardedAd?.paidEventHandler = { adValue in
                let adapterName = self?.rewardedAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: self?.rewardedAd?.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .rewarded,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: "USD",
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }
        }
    }

    func show(adPlacement _: AdPlacementRepresentable, adPlacementHigh _: AdPlacementRepresentable?) {
    /* use show(adPlacement:adPlacementHigh:onReward:) */ }

    @MainActor
    func show(
        adPlacement: AdPlacementRepresentable,
        adPlacementHigh: AdPlacementRepresentable?,
        onReward: @escaping (AdReward) -> Void
    ) {
        let primary = (adPlacementHigh?.isEnabled == true) ? adPlacementHigh! : adPlacement
        guard canShow(adPlacement: primary) else {
            onReward(.init())
            return
        }

        if let rewardedAd, let rootVC = topMostViewController() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                rewardedAd.present(from: rootVC) {
                    let reward = rewardedAd.adReward
                    onReward(reward)
                }
            })
            return
        }

        let request = Request()
        RewardedAd.load(with: primary.id, request: request) { [weak self] ad, error in
            if let error {
                print("Failed to load rewarded ad for \(primary.id): \(error.localizedDescription)")
                if let fallback = (adPlacementHigh?.isEnabled == true) ? adPlacement : nil {
                    self?.show(adPlacement: fallback, adPlacementHigh: nil, onReward: onReward)
                } else {
                    onReward(.init(rewardType: "Reward not exist", rewardAmount: 1))
                }
                return
            }
            guard let ad else {
                onReward(.init(rewardType: "Reward not exist", rewardAmount: 1))
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self

            self?.rewardedAd?.paidEventHandler = { adValue in
                let adapterName = self?.rewardedAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: self?.rewardedAd?.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .rewarded,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: "USD",
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }
            if let rootVC = self?.topMostViewController() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    ad.present(from: rootVC) {
                        let reward = ad.adReward
                        onReward(reward)
                    }
                })
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

extension RewardedAdService: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_: any FullScreenPresentingAd) {
        // No-op; keep reference while showing
    }

    func ad(_: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError _: any Error) {
        // Invalidate the cached ad on failure so next call will load a fresh one
        rewardedAd = nil
    }

    func adDidDismissFullScreenContent(_: any FullScreenPresentingAd) {
        // RewardedAd objects are single-use. Clear after dismissal to allow reloading next time.
        rewardedAd = nil
    }

    func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        if let interstitial = ad as? RewardedAd {
            let payload = ClickPayload(
                adUnitId: interstitial.adUnitID,
                adKind: .rewarded,
                timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
            )
            AdsEventManager.shared.logClick(payload)
        }
    }
}

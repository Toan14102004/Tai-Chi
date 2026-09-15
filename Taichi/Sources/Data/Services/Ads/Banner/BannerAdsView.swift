//
//  BannerAdsView.swift
//  ARDraw
//
//  Created by Toan Nguyen on 5/9/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import UIKit

// MARK: - Banner Ads View

struct BannerAdsView: View {
    
    enum Collapse: String {
        case top
        case bottom
    }
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Injected var keychainStorage: KeychainStorage
    @Injected var adMobManager: AdsManager

    let adPlacement: AdPlacement
    let adSize: AdSize
    var collapse: Collapse?

    @State private var reloadTrigger = UUID()
    @State private var isAdLoaded = true

    init(adPlacement: AdPlacement, adSize _: AdSize = AdSizeBanner, collapse: Collapse? = nil) {
        self.adPlacement = adPlacement
        self.collapse = collapse
        adSize = currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width - 0)
    }

    var body: some View {
        VStack {
            if subscriptionManager.hidesAds || !AppFlags.adsEnabled || !adPlacement.isEnabled || !isAdLoaded {
                // Empty - ad hidden
                EmptyView()
            } else {
                BannerAdsRepresentable(
                    adUnitID: adPlacement.id,
                    adSize: adSize,
                    adMobManager: adMobManager,
                    reloadTrigger: reloadTrigger,
                    collapse: collapse,
                    isAdLoaded: $isAdLoaded
                )
                .frame(height: 60)
            }
        }
    }

    private struct BannerAdsRepresentable: UIViewRepresentable {
        let adUnitID: String
        let adSize: AdSize
        let adMobManager: AdsManager
        let reloadTrigger: UUID
        var collapse: Collapse?
        @Binding var isAdLoaded: Bool

        func makeUIView(context: Context) -> BannerView {
            let bannerView = adMobManager.bannerAdService.createBannerView(adUnitID: adUnitID, adSize: adSize)
            bannerView.delegate = context.coordinator
            
            // Setup paid event handler
//            bannerView.paidEventHandler = { adValue in
//                let adapterName = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
//                let reveune = adValue.value.int64Value / 1_000_000
//                let payload = PaidImpressionPayload(
//                    adUnitId: bannerView.adUnitID ?? "",
//                    mediationAdapterClassName: adapterName,
//                    adKind: .banner,
//                    revenueMicros: reveune,
//                    precision: adValue.precision.rawValue,
//                    currencyCode: "USD",
//                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
//                )
//                AdsEventManager.shared.logger.logPaidAdImpression(payload)
//            }
//            
            bannerView.paidEventHandler = { adValue in
                let adapterName =
                bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                let payload = PaidImpressionPayload(
                    adUnitId: bannerView.adUnitID ?? "",
                    mediationAdapterClassName: adapterName,
                    adKind: .banner,
                    revenueMicros: adValue.value.doubleValue,
                    precision: adValue.precision.rawValue,
                    currencyCode: adValue.currencyCode,
                    timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                )
                AdsEventManager.shared.logPaidAdImpression(payload)
            }
            
            // Load ad with collapse setting
            adMobManager.bannerAdService.load(bannerView: bannerView, collapse: collapse)

            return bannerView
        }

        func updateUIView(_ uiView: BannerView, context _: Context) {
            // Reload ad when trigger changes
            adMobManager.bannerAdService.load(bannerView: uiView, collapse: collapse)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, BannerViewDelegate {
            let parent: BannerAdsRepresentable

            init(_ parent: BannerAdsRepresentable) {
                self.parent = parent
            }

            func bannerViewDidRecordClick(_ bannerView: BannerView) {
                if let unitID = bannerView.adUnitID {
                    let payload = ClickPayload(
                        adUnitId: unitID,
                        adKind: .banner,
                        timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
                    )
                    AdsEventManager.shared.logClick(payload)
                }
            }
            
            func bannerViewDidReceiveAd(_ bannerView: BannerView) {
                print("✅ Banner ad loaded successfully")
                print("✅ Banner collapse: \(bannerView.isCollapsible)")
                parent.isAdLoaded = true
            }
            
            func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
                print("❌ Banner ad failed to load: \(error.localizedDescription)")
                parent.isAdLoaded = false
            }
        }
    }
}

//
//  BannerAdService.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation
import GoogleMobileAds
import UIKit

final class BannerAdService: AdService {
    @Injected var keychainStorage: KeychainStorage

    func canShow(adPlacement: AdPlacementRepresentable) -> Bool {
        AppFlags.adsEnabled && adPlacement.isEnabled
    }

    func load(adPlacement _: AdPlacementRepresentable, adPlacementHigh _: AdPlacementRepresentable?) {
        /* N/A for banner view creation */
    }

    func show(adPlacement _: AdPlacementRepresentable, adPlacementHigh _: AdPlacementRepresentable?) {
        /* N/A: owner holds the view */
    }

    func createBannerView(adUnitID: String, adSize: AdSize = AdSizeBanner) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        
        bannerView.adUnitID = adUnitID
        
        bannerView.rootViewController = UIApplication.shared.currentUIWindow?.rootViewController
        return bannerView
    }

    func load(bannerView: BannerView, collapse: BannerAdsView.Collapse?) {
        guard AppFlags.adsEnabled else { return }
        
        // Safety check: Ensure rootViewController is present to prevent crashes (especially with FB Audience Network)
        if bannerView.rootViewController == nil {
            bannerView.rootViewController = UIApplication.shared.currentUIWindow?.rootViewController
        }
        
        guard bannerView.rootViewController != nil else {
            print("⚠️ BannerAdService: Skipping load - RootViewController is missing")
            return
        }
        
        let request = Request()
        
        // Add collapsible parameter if specified
        if let collapse = collapse {
            let extras = Extras()
            extras.additionalParameters = ["collapsible": collapse.rawValue]
            request.register(extras)
            
            print("🔄 Loading banner ad with collapsible: \(collapse.rawValue)")
        } else {
            print("🔄 Loading standard banner ad")
        }
        
        bannerView.load(request)
    }
}

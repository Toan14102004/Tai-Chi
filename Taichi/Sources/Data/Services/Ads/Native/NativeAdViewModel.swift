//
//  NativeAdViewModel.swift
//
//
//  Created by minghui on 2023/6/14.
//

import Foundation
import GoogleMobileAds
import SwiftUI

public class NativeAdViewModel: NSObject, ObservableObject, NativeAdLoaderDelegate {
    @Published public var nativeAd: NativeAd?
    @Published public var isLoading: Bool = false
    private var adLoader: AdLoader!
    private var adLoaderHeight: AdLoader?
    private var primaryAdUnitID: String
    private var fallbackAdUnitID: String?
    private var primaryAdEnabled: Bool
    private var fallbackAdEnabled: Bool
    private var lastRequestTime: Date?
    private var lastRequestTimeHeight: Date?
    public var requestInterval: Int
    private static var cachedAds: [String: NativeAd] = [:]
    private static var lastRequestTimes: [String: Date] = [:]
    let adChoicesPosition: AdChoicesPosition
    // Track which ad placement is currently being used
    private var isUsingHeightPlacement: Bool = false
    private let shouldCache: Bool

    init(adPlacement: AdPlacement, adPlacementHight: AdPlacement? = nil, requestInterval: Int = 1 * 60, adChoicesPosition: AdChoicesPosition = .topRightCorner, shouldCache: Bool = true) {
        self.primaryAdUnitID = adPlacementHight?.id ?? adPlacement.id
        self.fallbackAdUnitID = adPlacementHight != nil ? adPlacement.id : nil
        self.primaryAdEnabled = adPlacementHight?.isEnabled ?? adPlacement.isEnabled
        self.fallbackAdEnabled = adPlacementHight != nil ? adPlacement.isEnabled : true
        self.requestInterval = requestInterval
        self.adChoicesPosition = adChoicesPosition
        self.shouldCache = shouldCache
        
        // Check cache for both placements
        if shouldCache {
            if let heightId = adPlacementHight?.id, 
               adPlacementHight?.isEnabled == true,
               let cachedAd = NativeAdViewModel.cachedAds[heightId] {
                nativeAd = cachedAd
                isUsingHeightPlacement = true
                lastRequestTimeHeight = NativeAdViewModel.lastRequestTimes[heightId]
            } else if adPlacement.isEnabled,
                      let cachedAd = NativeAdViewModel.cachedAds[adPlacement.id] {
                nativeAd = cachedAd
                isUsingHeightPlacement = false
                lastRequestTime = NativeAdViewModel.lastRequestTimes[adPlacement.id]
            }
        }
    }
    
    // Convenience init for backward compatibility
    public init(adUnitID: String, requestInterval: Int = 1 * 60, adChoicesPosition: AdChoicesPosition = .topRightCorner) {
        self.primaryAdUnitID = adUnitID
        self.fallbackAdUnitID = nil
        self.primaryAdEnabled = true
        self.fallbackAdEnabled = true
        self.requestInterval = requestInterval
        self.adChoicesPosition = adChoicesPosition
        self.shouldCache = true
        nativeAd = NativeAdViewModel.cachedAds[adUnitID]
        lastRequestTime = NativeAdViewModel.lastRequestTimes[adUnitID]
    }

    public func refreshAd() {
        // Check if any placement is enabled
        guard primaryAdEnabled || fallbackAdEnabled else {
            print("[NativeAd] [\(primaryAdUnitID)] Refresh canceled: No active placements")
            return
        }

        let now = Date()

        // Check if we have a cached ad and it's still valid
        if nativeAd != nil {
            let lastRequest = isUsingHeightPlacement ? lastRequestTimeHeight : lastRequestTime
//            if let lastRequest = lastRequest,
//               now.timeIntervalSince(lastRequest) < Double(requestInterval) {
//                print("[NativeAd] [\(primaryAdUnitID)] Refresh canceled: Throttled (last request < \(requestInterval / 60)m ago)")
//                return
//            }
        }

        guard !isLoading else {
            print("[NativeAd] [\(primaryAdUnitID)] Refresh canceled: Already loading")
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Try to load primary ad (adPlacementHeight) first if enabled
        if fallbackAdUnitID != nil && primaryAdEnabled {
            loadPrimaryAd()
        } else if fallbackAdEnabled {
            // Only fallback placement available and enabled, load it directly
            loadAdWithUnitID(fallbackAdUnitID ?? primaryAdUnitID)
        } else if primaryAdEnabled {
            // Only primary placement available and enabled, load it directly
            loadAdWithUnitID(primaryAdUnitID)
        }
    }
    
    private func loadPrimaryAd() {
        guard primaryAdEnabled else {
            print("[NativeAd] [\(primaryAdUnitID)] Primary disabled, skipping")
            // Try fallback if available and enabled
            if fallbackAdEnabled {
                loadFallbackAd()
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            return
        }
        
        let now = Date()
        lastRequestTimeHeight = now
        NativeAdViewModel.lastRequestTimes[primaryAdUnitID] = now
        let rootVC = topMostViewController()
        let adViewOptions = NativeAdViewAdOptions()
        adViewOptions.preferredAdChoicesPosition = adChoicesPosition
        
        print("[NativeAd] [\(primaryAdUnitID)] Requesting PRIMARY ad...")
        adLoaderHeight = AdLoader(adUnitID: primaryAdUnitID, rootViewController: rootVC, adTypes: [.native], options: [adViewOptions])
        adLoaderHeight?.delegate = self
        adLoaderHeight?.load(Request())
    }
    
    private func loadFallbackAd() {
        guard let fallbackID = fallbackAdUnitID, fallbackAdEnabled else { 
            print("[NativeAd] [\(primaryAdUnitID)] Fallback disabled or missing, stopping")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        let now = Date()
        lastRequestTime = now
        NativeAdViewModel.lastRequestTimes[fallbackID] = now
        let rootVC = topMostViewController()
        let adViewOptions = NativeAdViewAdOptions()
        adViewOptions.preferredAdChoicesPosition = adChoicesPosition
        
        print("[NativeAd] [\(fallbackID)] Requesting FALLBACK ad...")
        adLoader = AdLoader(adUnitID: fallbackID, rootViewController: rootVC, adTypes: [.native], options: [adViewOptions])
        adLoader.delegate = self
        adLoader.load(Request())
    }
    
    private func loadAdWithUnitID(_ adUnitID: String) {
        let now = Date()
        lastRequestTime = now
        NativeAdViewModel.lastRequestTimes[adUnitID] = now

        let adViewOptions = NativeAdViewAdOptions()
        adViewOptions.preferredAdChoicesPosition = adChoicesPosition
        adLoader = AdLoader(adUnitID: adUnitID, rootViewController: nil, adTypes: [.native], options: [adViewOptions])
        adLoader.delegate = self
        adLoader.load(Request())
    }

    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("[NativeAd] [\(adLoader.adUnitID)] Received ad successfully")
        self.nativeAd = nativeAd
        nativeAd.delegate = self
        DispatchQueue.main.async {
            self.isLoading = false
        }
        
        // Determine which placement this ad is from
        if adLoader == adLoaderHeight {
            isUsingHeightPlacement = true
            if shouldCache {
                NativeAdViewModel.cachedAds[primaryAdUnitID] = nativeAd
            }
        } else {
            isUsingHeightPlacement = false
            let adUnitID = fallbackAdUnitID ?? primaryAdUnitID
             if shouldCache {
                 NativeAdViewModel.cachedAds[adUnitID] = nativeAd
             }
        }
        
        nativeAd.mediaContent.videoController.delegate = self
        nativeAd.paidEventHandler = { adValue in
            let adapterName = nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
            let payload = PaidImpressionPayload(
                adUnitId: adLoader.adUnitID,
                mediationAdapterClassName: adapterName,
                adKind: .native,
                revenueMicros: adValue.value.doubleValue,
                precision: adValue.precision.rawValue,
                currencyCode: "USD",
                timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
            )
            AdsEventManager.shared.logPaidAdImpression(payload)
        }
    }

    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("[NativeAd] [\(adLoader.adUnitID)] Failed to load: \(error.localizedDescription)")
        
        // If primary ad (height) failed and we have a fallback that's enabled, try the fallback
        if adLoader == adLoaderHeight && fallbackAdUnitID != nil && fallbackAdEnabled {
            print("[NativeAd] [\(primaryAdUnitID)] Primary failed, attempting fallback to \(fallbackAdUnitID ?? "")")
            loadFallbackAd()
        } else {
            // No fallback available, fallback is disabled, or fallback also failed
            print("[NativeAd] [\(primaryAdUnitID)] All attempts failed, giving up")
            DispatchQueue.main.async {
                self.isLoading = false
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

extension NativeAdViewModel: VideoControllerDelegate {
    // GADVideoControllerDelegate methods
    public func videoControllerDidPlayVideo(_: VideoController) {
        // Implement this method to receive a notification when the video controller
        // begins playing the ad.
    }

    public func videoControllerDidPauseVideo(_: VideoController) {
        // Implement this method to receive a notification when the video controller
        // pauses the ad.
    }

    public func videoControllerDidEndVideoPlayback(_: VideoController) {
        // Implement this method to receive a notification when the video controller
        // stops playing the ad.
    }

    public func videoControllerDidMuteVideo(_: VideoController) {
        // Implement this method to receive a notification when the video controller
        // mutes the ad.
    }

    public func videoControllerDidUnmuteVideo(_: VideoController) {
        // Implement this method to receive a notification when the video controller
        // unmutes the ad.
    }
}

// MARK: - GADNativeAdDelegate implementation

extension NativeAdViewModel: NativeAdDelegate {
    public func nativeAdDidRecordClick(_: NativeAd) {
        let currentAdUnitID = isUsingHeightPlacement ? primaryAdUnitID : (fallbackAdUnitID ?? primaryAdUnitID)
        let payload = ClickPayload(
            adUnitId: currentAdUnitID,
            adKind: .native,
            timestampMs: Int64(Date().timeIntervalSince1970 * 1000)
        )
        AdsEventManager.shared.logClick(payload)
    }

    public func nativeAdDidRecordImpression(_: NativeAd) {
        print("[NativeAd] Impression recorded")
    }

    public func nativeAdWillPresentScreen(_: NativeAd) {
        print("\(#function) called")
    }

    public func nativeAdWillDismissScreen(_: NativeAd) {
        print("\(#function) called")
    }

    public func nativeAdDidDismissScreen(_: NativeAd) {
        print("\(#function) called")
    }
}

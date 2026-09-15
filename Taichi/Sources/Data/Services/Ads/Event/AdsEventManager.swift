//
//  AdsEventManager.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation

final class AdsEventManager {
    static let shared = AdsEventManager()
    
    private init() {}

    private var logger: AdsEventLogging = AdsEventLogger()
    
    func logPaidAdImpression(_ payload: PaidImpressionPayload) {
        Logger.d(messages: "paid_ad_impression", payload.adUnitId, payload.adKind.rawValue)
        
        logger.logPaidAdImpression(payload)
    }

    func logPaidAdImpressionValue(_ payload: PaidImpressionValuePayload) {
        Logger.d(messages: "paid_ad_impression_value", payload.adUnitId, payload.value)
        
        logger.logPaidAdImpressionValue(payload)
    }

    func logClick(_ payload: ClickPayload) {
        Logger.d(messages: "event_user_click_ads", payload.adUnitId, payload.adKind.rawValue)
        
        logger.logClick(payload)
    }

    func logCurrentTotalRevenueAd(eventName: String, value: Float) {
        Logger.d(messages: eventName, value)
        
        logger.logCurrentTotalRevenueAd(eventName: eventName, value: value)
    }
}

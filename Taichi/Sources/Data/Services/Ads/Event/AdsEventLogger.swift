//
//  AdsEventLogger.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation
import FBSDKCoreKit

protocol AdsEventLogging {
    func logPaidAdImpression(_ payload: PaidImpressionPayload)
    func logPaidAdImpressionValue(_ payload: PaidImpressionValuePayload)
    func logClick(_ payload: ClickPayload)
    func logCurrentTotalRevenueAd(eventName: String, value: Float)
}

final class AdsEventLogger: AdsEventLogging {
    func logPaidAdImpression(_ payload: PaidImpressionPayload) {
        Logger.d(messages: "paid_ad_impression", payload.adUnitId, payload.adKind.rawValue)
        
        let revenueInStandardUnit = payload.revenueMicros / 1_000_000.0
        
        AppEvents.shared.logEvent(
            .adImpression,
            valueToSum: revenueInStandardUnit,
            parameters: [
                AppEvents.ParameterName.currency: payload.currencyCode,
                AppEvents.ParameterName("ad_unit_id"): payload.adUnitId,
                AppEvents.ParameterName("ad_kind"): payload.adKind.rawValue,
                AppEvents.ParameterName("mediation_adapter"): payload.mediationAdapterClassName,
                AppEvents.ParameterName("revenue_micros"): payload.revenueMicros,
                AppEvents.ParameterName("precision"): payload.precision,
                AppEvents.ParameterName("currency_code"): payload.currencyCode,
                AppEvents.ParameterName("timestamp_ms"): payload.timestampMs
            ]
        )
        
        AppEvents.shared.logPurchase(
            amount: revenueInStandardUnit,
            currency: payload.currencyCode,
            parameters: [
                AppEvents.ParameterName("ad_unit_id"): payload.adUnitId,
                AppEvents.ParameterName("ad_kind"): payload.adKind.rawValue,
                AppEvents.ParameterName("mediation_adapter"): payload.mediationAdapterClassName,
                AppEvents.ParameterName("revenue_micros"): payload.revenueMicros,
                AppEvents.ParameterName("precision"): payload.precision,
                AppEvents.ParameterName("currency_code"): payload.currencyCode,
                AppEvents.ParameterName("timestamp_ms"): payload.timestampMs
            ]
        )
    }

    func logPaidAdImpressionValue(_ payload: PaidImpressionValuePayload) {
        Logger.d(messages: "paid_ad_impression_value", payload.adUnitId, payload.value)
        
        // Facebook event logging
        AppEvents.shared.logEvent(
            .adImpression,
            parameters: [
                AppEvents.ParameterName("ad_unit_id"): payload.adUnitId,
                AppEvents.ParameterName("value"): payload.value,
                AppEvents.ParameterName("precision"): payload.precision,
                AppEvents.ParameterName("network"): payload.network
            ]
        )
    }

    func logClick(_ payload: ClickPayload) {
        Logger.d(messages: "event_user_click_ads", payload.adUnitId, payload.adKind.rawValue)
        
        // Facebook event logging
        AppEvents.shared.logEvent(
            .adClick,
            parameters: [
                AppEvents.ParameterName("ad_unit_id"): payload.adUnitId,
                AppEvents.ParameterName("ad_kind"): payload.adKind.rawValue,
                AppEvents.ParameterName("timestamp_ms"): payload.timestampMs
            ]
        )
    }

    func logCurrentTotalRevenueAd(eventName: String, value: Float) {
        Logger.d(messages: eventName, value)
        
        // Facebook event logging
        AppEvents.shared.logEvent(
            AppEvents.Name(eventName),
            parameters: [
                AppEvents.ParameterName("value"): value
            ]
        )
    }
}



//
//  Subscription.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/6/25.
//

import Foundation
import SwiftUI

enum AutoRenewableSubscription: String {
    case yearly
    case monthly
    case weekly
    case weeklyFreeTrial = "weekly.freetrial"
    case monthlyFreeTrial = "monthly.freetrial"
    case yearlyFreeTrial = "yearly.freetrial"

    private static let prefix = "com.limgrow.taichi."

    init?(productId: String) {
        guard productId.hasPrefix(Self.prefix) else {
            return nil
        }
        let typeString = String(productId.dropFirst(Self.prefix.count))
        self.init(rawValue: typeString)
    }

    var productId: String {
        Self.prefix + rawValue
    }

    var displayName: LocalizedStringKey {
        switch self {
        case .yearly: "Yearly"
        case .monthly: "Monthly"
        case .weekly: "Weekly"
        case .weeklyFreeTrial: "Weekly"
        case .monthlyFreeTrial: "Monthly"
        case .yearlyFreeTrial: "Yearly"
        }
    }

    var periodString: String {
        rawValue.capitalized
    }
}

// MARK: - Non-Consumable Lifetime

enum NonConsumableProduct: String {
    case lifetime
    case lifetimeIntroduce = "lifetime.introduce"

    private static let prefix = "com.limgrow.taichi."

    init?(productId: String) {
        guard productId.hasPrefix(Self.prefix) else { return nil }
        let typeString = String(productId.dropFirst(Self.prefix.count))
        self.init(rawValue: typeString)
    }

    var productId: String { Self.prefix + rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .lifetime: "Lifetime"
        case .lifetimeIntroduce: "Lifetime"
        }
    }

    var periodString: String {
        rawValue.capitalized
    }

    var type: LocalizedStringKey { "One-time purchase" }
}

extension SubscriptionManager {
    enum SubscriptionStatus {
        case notSubscribed
        case lifetime
        case subscribed(expiryDate: Date)
        case expired
        case unknown
    }

    struct SubscriptionInfo {
        let productId: String
        let displayName: LocalizedStringKey
        let purchaseDate: Date
        let expiryDate: Date
        let isActive: Bool
        let isInTrialPeriod: Bool
        let isInIntroOfferPeriod: Bool
        let subscriptionPeriod: String
        let introductoryOfferInfo: IntroductoryOfferInfo?

        var statusDescription: String {
            if isInTrialPeriod {
                "Free Trial"
            } else if isInIntroOfferPeriod {
                "Introductory Offer"
            } else {
                "Regular Subscription"
            }
        }
        
    }

    struct IntroductoryOfferInfo {
        let type: IntroductoryOfferType
        let price: Decimal
        let priceLocale: Locale
        let numberOfPeriods: Int
        let subscriptionPeriod: String
        let isEligible: Bool

        enum IntroductoryOfferType {
            case freeTrial
            case payAsYouGo
            case payUpFront
            
            var localizedDescription: LocalizedStringKey {
                switch self {
                case .freeTrial:
                    "Start Free Trial"
                case .payAsYouGo:
                    "Pay as You Go"
                case .payUpFront:
                    "Pay Up Front"
                }
            }
        }

        var displayText: LocalizedStringKey {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            let priceString = formatter.string(from: NSDecimalNumber(decimal: price)) ?? ""

            switch type {
            case .freeTrial:
                return "\(subscriptionPeriod) Free Trial"
            case .payAsYouGo:
                return "\(priceString) for \(numberOfPeriods) \(subscriptionPeriod)"
            case .payUpFront:
                return "\(priceString) for \(numberOfPeriods) \(subscriptionPeriod)"
            }
        }
    }
}

//
//  SubscriptionError.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/6/25.
//

import Foundation
import StoreKit

extension SKError {
    var errorMessage: String {
        switch code {
        case .unknown: "Unknown error occurred"
        case .clientInvalid: "Not allowed to make payments"
        case .paymentCancelled: "Payment cancelled"
        case .paymentInvalid: "Invalid payment"
        case .paymentNotAllowed: "Payment not allowed"
        case .storeProductNotAvailable: "Product not available"
        default: "Purchase failed: \(localizedDescription)"
        }
    }
}

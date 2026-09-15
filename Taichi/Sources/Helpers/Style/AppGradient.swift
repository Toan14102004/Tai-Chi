//
//  AppGradient.swift
//  Taichi
//
//  Created by Toan Nguyen on 29/9/25.
//

import Foundation
import SwiftUI
import UIKit

enum AppGradient {
    /// Native ad CTA button (Figma style `button/ads`, e.g. node 4082:7107 `Button`).
    /// #869477 -> #93C06C, horizontal (leading to trailing).
    static let startColor = Color(hex: "#869477")
    static let endColor = Color(hex: "#93C06C")

    static var mainGradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// "Premium Access" card on the Profile tab (Figma: FLow Profile / 01 — Overview).
    /// #FFB5CA -> #FFA220, horizontal (leading to trailing).
    static var premiumCard: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#FFB5CA"), Color(hex: "#FFA220")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// UIKit equivalent for views that aren't SwiftUI (e.g. native ad templates).
    static func makeCAGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#869477").cgColor,
            UIColor(hex: "#93C06C").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }
}

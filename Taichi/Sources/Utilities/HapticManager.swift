//
//  HapticManager.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/6/25.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // MARK: - Selection Feedback

    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

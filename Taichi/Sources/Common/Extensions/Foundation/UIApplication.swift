//
//  UIApplication.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/9/25.
//

import Foundation
import UIKit

extension UIApplication {
    var currentUIWindow: UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        
        // First try to find a key window in a foreground active scene
        if let window = connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) {
            return window
        }
        
        // Fallback: try to find any key window
        return connectedScenes
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })
    }

    var safeAreaInsets: UIEdgeInsets {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow })

        return keyWindow?.safeAreaInsets ?? .zero
    }

    var safeAreaTop: CGFloat {
        safeAreaInsets.top
    }

    var safeAreaBottom: CGFloat {
        safeAreaInsets.bottom
    }

    var safeAreaLeft: CGFloat {
        safeAreaInsets.left
    }

    var safeAreaRight: CGFloat {
        safeAreaInsets.right
    }
}

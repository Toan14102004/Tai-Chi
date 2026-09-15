//
//  ShareView.swift
//  Taichi
//
//  Created by Toan Nguyen on 10/9/25.
//

import Foundation
import SwiftUI
import UIKit

public func openShareView(
    _ items: [some Any],
    onDismiss: (() -> Void)? = nil,
    onSuccess: ((UIActivity.ActivityType?) -> Void)? = nil,
    onError: ((Error?) -> Void)? = nil
) {
    DispatchQueue.main.async {
        let share = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Completion handler xử lý kết quả share
        share.completionWithItemsHandler = { activityType, completed, _, error in
            if let error {
                onError?(error)
            } else if completed {
                onSuccess?(activityType)
            }
            onDismiss?()
        }

        guard let presenter = topMostViewController() else { return }

        // Tránh double-present nếu UIActivityViewController đã hiển thị
        if presenter is UIActivityViewController {
            return
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            share.popoverPresentationController?.sourceView = presenter.view
            share.popoverPresentationController?.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            share.popoverPresentationController?.permittedArrowDirections = []
        }

        // Nếu presenter đang trình bày controller khác, cố gắng trình bày từ controller trên cùng
        let top = presenter.presentedViewController ?? presenter
        top.present(share, animated: true)
    }

    func topMostViewController() -> UIViewController? {
        // iOS 13+: lấy từ active windowScene
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        guard let windowScene = scenes.first,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var top = window.rootViewController else {
            return nil
        }

        func traverse(_ vc: UIViewController) -> UIViewController {
            if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
                return traverse(visible)
            }
            if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
                return traverse(selected)
            }
            if let presented = vc.presentedViewController {
                return traverse(presented)
            }
            return vc
        }

        top = traverse(top)
        return top
    }
}

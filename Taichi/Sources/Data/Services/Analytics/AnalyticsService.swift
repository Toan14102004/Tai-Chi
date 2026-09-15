//
//  AnalyticsService.swift
//  Taichi
//
//  Created by Toan Nguyen on 22/8/26.
//

import Foundation

enum AnalyticsParameterKey {
    static let screen = "screen"
    static let step = "step"
    static let fromStep = "fromStep"
    static let template = "template"
    static let hasLocation = "hasLocation"
    static let status = "status"
    static let result = "result"
    static let mediaType = "mediaType"
    static let reason = "reason"
    static let source = "source"
    static let mediaId = "mediaId"
    static let foodId = "foodId"
    static let tool = "tool"
    static let placement = "placement"
    static let next = "next"
    static let query = "query"
    static let language = "language"
    static let destination = "destination"
    static let productId = "productId"
    static let style = "style"
    static let type = "type"
    static let answer = "answer"
    static let hasText = "hasText"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let locationId = "locationId"
    static let videoId = "videoId"
    static let isEnabled = "isEnabled"
    static let decision = "decision"
    static let fromSplash = "fromSplash"
    static let isOnboarding = "isOnboarding"
}

/// Local, dependency-free analytics logging. No remote reporting backend is wired up —
/// this only surfaces events to the console in debug builds. Swap the body of these
/// methods for whatever analytics SDK the app adopts in the future.
class AnalyticsService: Service {
    var shouldAutostart: Bool { true }

    func start() {}

    func stop() {}

    // MARK: - Screen Tracking

    /// Track screen view với tên màn hình
    /// - Parameters:
    ///   - name: Tên màn hình (ví dụ: "home_screen")
    ///   - parameters: Các tham số bổ sung (optional)
    func trackScreen(name: String, parameters: [String: Any]? = nil) {
        log(event: "screen_view", name: name, parameters: parameters)
    }

    // MARK: - Event Tracking

    /// Track custom event
    /// - Parameters:
    ///   - name: Tên event
    ///   - parameters: Các tham số của event
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        log(event: name, name: name, parameters: parameters)
    }

    /// Preferred helper for logging analytics events.
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        trackEvent(name: name, parameters: parameters)
    }

    private func log(event: String, name: String, parameters: [String: Any]?) {
        #if DEBUG
        print("[AnalyticsService] \(event): \(name) \(parameters ?? [:])")
        #endif
    }
}

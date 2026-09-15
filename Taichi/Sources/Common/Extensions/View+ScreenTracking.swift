//
//  View+ScreenTracking.swift
//  Taichi
//
//  Created by Auto on 11/2/25.
//

import SwiftUI

extension View {
    /// Track screen view khi view xuất hiện
    /// - Parameters:
    ///   - screenName: Tên màn hình để track (ví dụ: "home_screen")
    ///   - parameters: Các tham số bổ sung (optional)
    /// - Returns: View với screen tracking modifier
    func trackScreen(_ screenName: String, parameters: [String: Any]? = nil) -> some View {
        self.modifier(ScreenTrackingModifier(screenName: screenName, parameters: parameters))
    }
    
    /// Track impression event khi view xuất hiện
    /// - Parameters:
    ///   - eventName: Tên event để track (ví dụ: "PW_Home_impression")
    ///   - parameters: Các tham số bổ sung (optional)
    /// - Returns: View với impression tracking modifier
    func trackImpression(_ eventName: String, parameters: [String: Any]? = nil) -> some View {
        self.modifier(ImpressionTrackingModifier(eventName: eventName, parameters: parameters))
    }
}

private struct ScreenTrackingModifier: ViewModifier {
    let screenName: String
    let parameters: [String: Any]?
    
    @Injected var analyticsService: AnalyticsService
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analyticsService.trackScreen(name: screenName, parameters: parameters)
            }
    }
}

private struct ImpressionTrackingModifier: ViewModifier {
    let eventName: String
    let parameters: [String: Any]?
    
    @Injected var analyticsService: AnalyticsService
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analyticsService.trackEvent(name: eventName, parameters: parameters)
            }
    }
}


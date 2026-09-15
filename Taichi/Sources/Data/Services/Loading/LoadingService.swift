//
//  LoadingService.swift
//  Wallpaper
//
//  Created by Auto on 20/1/25.
//

import Foundation
import SwiftUI

/// Service quản lý việc hiển thị loading cho toàn bộ app
class LoadingService: ObservableObject {
    @Published var isLoading: Bool = false
    
    let indicatorType: ActivityIndicatorView.IndicatorType = .rotatingDots(count: 8)
    
    let indicatorColor: Color = Asset.Color.primary.color
    
    @MainActor
    func show() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    @MainActor
    func hide() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}


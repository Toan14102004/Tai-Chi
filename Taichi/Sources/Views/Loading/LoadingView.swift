//
//  LoadingView.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/1/26.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var isLoading: Bool
    
    var body: some View {
        ActivityIndicatorView(
            isVisible: $isLoading,
            type: .rotatingDots(count: 8)
        )
        .foregroundColor(Asset.Color.mainColor.color)
        .frame(
            width: Layout.Spacing.xxl,
            height: Layout.Spacing.xxl
        )
    }
}

#Preview {
    LoadingView(isLoading: .constant(true))
}

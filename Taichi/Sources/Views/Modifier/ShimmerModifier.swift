//
//  ShimmerModifier.swift
//  Taichi
//
//  Created by Guest User on 6/2/26.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    var active: Bool
    
    func body(content: Content) -> some View {
        if active {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: Asset.Color.white.color.opacity(0.3), location: 0.3),
                                .init(color: Asset.Color.white.color.opacity(0.5), location: 0.5),
                                .init(color: Asset.Color.white.color.opacity(0.3), location: 0.7),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    }
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func shimmering(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

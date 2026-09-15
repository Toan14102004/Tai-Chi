//
//  CircleButtonStyle.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation
import SwiftUI

struct FloatIconButtonStyle: ButtonStyle {
    var padding: CGFloat
    var background: AnyShapeStyle

    init(
        padding: CGFloat = Layout.Spacing.m,
        background: some ShapeStyle = Asset.Color.white.color,
    ) {
        self.padding = padding
        self.background = AnyShapeStyle(background)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Asset.Color.black.color)
            .padding(padding)
            .background(Asset.Color.mainColor.color)
            .clipShape(SquareShape(cornerRadius: Layout.CornerRadius.large))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .padding(1)
    }
}

#Preview {
    Button(action: {
        print("Back tapped")
    }) {
        Image(systemName: "arrow.left")
            .font(.system(size: 28, weight: .semibold))
    }
    .buttonStyle(FloatIconButtonStyle())
}

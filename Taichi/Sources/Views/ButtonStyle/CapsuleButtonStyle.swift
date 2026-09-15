//
//  CapsuleButtonStyle.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation
import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    var background: AnyShapeStyle
    var paddingVertical: CGFloat
    
    init(
        background: some ShapeStyle = Asset.Color.mainColor.color,
        paddingVertical: CGFloat = Layout.Spacing.s
    ) {
        self.background = AnyShapeStyle(background)
        self.paddingVertical = paddingVertical
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Asset.Color.black.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, paddingVertical)
            .background(
                Capsule()
                    .fill(background)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .padding(1)
    }
}

#Preview(body: {
    Button(action: {
        print("Chat tapped")
    }) {
        HStack(spacing: 6) {
            Image(systemName: "message.fill")
                .foregroundColor(.blue)

            Text("Let’s Chat!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.pink, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
    .buttonStyle(CapsuleButtonStyle())
})

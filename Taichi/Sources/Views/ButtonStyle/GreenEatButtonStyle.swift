//
//  TaichiButtonStyle.swift
//  Taichi
//
//  Created by Toan Nguyen on 15/9/25.
//

import Foundation
import SwiftUI

struct TaichiButtonStyle: ButtonStyle {
    var border: AnyShapeStyle
    var borderWidth: CGFloat
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var fill: Color?

    init(
        border: some ShapeStyle = Asset.Color.mainColor.color,
        borderWidth: CGFloat = Layout.StrokeWidth.thick,
        verticalPadding: CGFloat = Layout.Spacing.m,
        horizontalPadding: CGFloat = Layout.Spacing.m,
        fill: Color? = nil
    ) {
        self.border = AnyShapeStyle(border)
        self.borderWidth = borderWidth
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.fill = fill
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(
                Group {
                    if let fill {
                        Capsule().fill(fill)
                    } else {
                        Color.clear
                    }
                }
            )
            .background(
                Capsule()
                    .stroke(border, lineWidth: borderWidth)
            )
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .padding(1)
    }
}

#Preview(body: {
    VStack {
        Button {} label: {
            Text("M.T.G Taichis")
                .foregroundStyle(.white)
        }
        .buttonStyle(TaichiButtonStyle())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
})

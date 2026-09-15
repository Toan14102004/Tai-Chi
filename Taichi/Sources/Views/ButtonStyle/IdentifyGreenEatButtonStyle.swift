//
//  TaichiButtonStyle.swift
//  Taichi
//
//  Created by Toan Nguyen on 15/9/25.
//

import Foundation
import SwiftUI

struct IdentifyTaichiButtonStyle: ButtonStyle {
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat

    init(
        verticalPadding: CGFloat = Layout.Spacing.m,
        horizontalPadding: CGFloat = Layout.Spacing.l
    ) {
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .foregroundStyle(Asset.Color.black.color)
            .background(
                Capsule()
                    .fill(Asset.Color.mainColor.color)
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

#Preview {
    VStack {
        Button {} label: {
            HStack (spacing: Layout.Spacing.xs) {
                Asset.Icon.Commo.plus.image
                    .toIcon()
                
                Text("Identify")
            }
        }
        .buttonStyle(IdentifyTaichiButtonStyle())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}

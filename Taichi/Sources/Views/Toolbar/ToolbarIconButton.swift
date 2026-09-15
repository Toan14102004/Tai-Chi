//
//  ToolbarIconButton.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation
import SwiftUI

struct ToolbarIconButton: ToolbarContent {
    var placement: ToolbarItemPlacement = .automatic
    let icon: Image
    var color: Color = Asset.Color.black.color
    let action: () -> Void
    var sizeIcon: CGFloat = Layout.Icon.large

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button {
                action()
            } label: {
                icon
                    .toIcon(sizeIcon)
                    .foregroundStyle(color)
            }
        }
    }
}

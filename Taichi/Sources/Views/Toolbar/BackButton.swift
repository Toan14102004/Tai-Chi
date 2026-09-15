//
//  BackButton.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation
import SwiftUI

struct BackButton: ToolbarContent {
    var icon: Image = Asset.Icon.Commo.arrowLeft.image
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                action()
            } label: {
                icon
                    .toIcon(Layout.Icon.large)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
        }
    }
}

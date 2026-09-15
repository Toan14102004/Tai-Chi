//
//  ToolbarTitle.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation
import SwiftUI

struct ToolbarTitle: ToolbarContent {
    var title: LocalizedStringKey
    var colorText: Color = Asset.Color.mainColor.color

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(FontFamily.Inter.regular.font(size: Layout.Text.headline))
                .foregroundStyle(colorText)
        }
    }
}

struct ToolbarDescription: ToolbarContent {
    var placement: ToolbarItemPlacement = .automatic
    var description: LocalizedStringKey

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Text(description)
                .font(FontFamily.Inter.bold.font(size: Layout.Text.headline))
                .foregroundStyle(Asset.Color.white.color)
        }
    }
}



//
//  PremiumButton.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation
import Lottie
import SwiftUI

struct PremiumButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                action()
            } label: {
                LottieView(animation: .named("crown.json"))
                    .looping()
                    .frame(width: Layout.Icon.large)
            }
        }
    }
}

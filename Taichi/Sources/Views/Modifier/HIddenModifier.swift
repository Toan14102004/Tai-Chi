//
//  HIddenModifier.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/10/25.
//

import Foundation
import SwiftUI

extension View {
    /// Ẩn hoặc hiện view dựa trên giá trị Boolean
    @ViewBuilder
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}


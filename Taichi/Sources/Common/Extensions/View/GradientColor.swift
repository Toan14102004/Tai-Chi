//
//  GradientColor.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/11/25.
//

import Foundation
import SwiftUI

enum GradientColor {
    static let primaryBlueGradientHorizontal = ColorGradient(
        gradient: LinearGradient(
            colors: [
                Color(hex: "#00C6FF"),
                Color(hex: "#0072FF"),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
}

class ColorGradient {
    let gradient: AnyShapeStyle
    
    init(gradient: some ShapeStyle) {
        self.gradient = AnyShapeStyle(gradient)
    }
}

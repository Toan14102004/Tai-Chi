//
//  Image+Extension.swift
//  Taichi
//
//  Created by Toan Nguyen on 4/9/25.
//

import Foundation
import SwiftUI

extension Image {
    func toIcon(_ size: CGFloat = Layout.Icon.medium) -> some View {
        resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

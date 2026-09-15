//
//  ToolbarColor.swift
//  Taichi
//
//  Created by Toan Nguyen on 3/10/25.
//

import Foundation
import SwiftUI

extension View {
    func toolbarColor(background: UIColor, title: UIColor = .white) -> some View {
        modifier(ToolbarColorModifier(backgroundColor: background, titleColor: title))
    }
}

struct ToolbarColorModifier: ViewModifier {
    var backgroundColor: UIColor
    var titleColor: UIColor

    init(backgroundColor: UIColor, titleColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = titleColor
    }

    func body(content: Content) -> some View {
        content
    }
}

//
//  BaseView.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/2/25.
//

import SwiftUI

struct BaseView<Content: View>: View {
    @Environment(\.dismiss) var dismiss

    var background: AnyShapeStyle
    let content: Content
    let onBackAction: (() -> Void)? = nil

    init(background: some ShapeStyle = Asset.Color.bgCanvas.color, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.background = AnyShapeStyle(background)
    }

    var body: some View {
        ZStack {
            content
        }
        .foregroundStyle(.white)
        .colorScheme(.light)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(background)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
    }
}

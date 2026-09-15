//
//  CustomEmptyView.swift
//  Taichi
//
//  Created by Toan Nguyen on 17/9/25.
//

import SwiftUI

struct CustomEmptyView: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let icon: Image
    let buttonDescription: LocalizedStringKey
    var action: () -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            Image(systemName: "photo")
                .toIcon(Layout.Icon.xl * 1.5)

            VStack(spacing: Layout.Spacing.m) {
                Text(title)

                Text(description)
            }

            Button {
                action()
            } label: {
                HStack {
                    icon
                        .toIcon(Layout.Icon.small)

                    Text(buttonDescription)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F3F4F8"))
    }
}

#Preview {
    CustomEmptyView(
        title: "No Knowledge Sources",
        description: "Create your first knowledge source to get started",
        icon: Image(systemName: "photo"),
        buttonDescription: "Create Knowledge Source",
        action: {}
    )
}

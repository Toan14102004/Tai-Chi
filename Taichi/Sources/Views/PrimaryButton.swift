//
//  PrimaryButton.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemIcon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.xs) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title.localizedKey)
                    .font(FontFamily.Inter.medium.font(size: 16))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Asset.Color.mainColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PrimaryButton(title: "Get Started", systemIcon: nil) {}
        .padding()
}

//
//  ProfileSetupOptionCell.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct ProfileSetupOptionCell: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.localizedKey)
                .font(Typography.bodyLarge)
                .foregroundStyle(isSelected ? Asset.Color.white.color : Asset.Color.textPrimary.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
                .padding(.horizontal, Layout.Spacing.m)
                .background(isSelected ? Asset.Color.secondaryColor.color : Color.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Asset.Color.optionBorder.color, lineWidth: isSelected ? 0 : 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Layout.Spacing.s) {
        ProfileSetupOptionCell(title: "Get in shape", isSelected: false, action: {})
        ProfileSetupOptionCell(title: "Look Better", isSelected: true, action: {})
    }
    .padding()
    .background(Asset.Color.bgPrimary.color)
}

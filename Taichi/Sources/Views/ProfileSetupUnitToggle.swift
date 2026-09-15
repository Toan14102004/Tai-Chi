//
//  ProfileSetupUnitToggle.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct ProfileSetupUnitToggle<Unit: Hashable>: View {
    let options: [(unit: Unit, label: String)]
    @Binding var selection: Unit

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.unit) { option in
                Button {
                    selection = option.unit
                } label: {
                    Text(option.label)
                        .font(Typography.labelMedium)
                        .foregroundStyle(
                            selection == option.unit ? Asset.Color.textPrimary.color : Asset.Color.textSecondary.color
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selection == option.unit ? Asset.Color.white.color : .clear)
                        .clipShape(Capsule())
                        .shadow(
                            color: .black.opacity(selection == option.unit ? Layout.Opacity.light : 0),
                            radius: 4, x: 0, y: 2
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(hex: "F7F7F7"))
        .clipShape(Capsule())
    }
}

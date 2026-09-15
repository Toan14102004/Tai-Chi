//
//  WeekdayChip.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// A 32pt circular day toggle used by the reminder cards.
struct WeekdayChip: View {
    let label: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Typography.labelMedium)
                .foregroundStyle(isOn ? Asset.Color.white.color : Asset.Color.textSecondary.color)
                .frame(width: 32, height: 32)
                .background(isOn ? Asset.Color.secondaryColor.color : Asset.Color.white.color)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

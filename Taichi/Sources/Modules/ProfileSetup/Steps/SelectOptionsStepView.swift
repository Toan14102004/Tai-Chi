//
//  SelectOptionsStepView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

/// Renders a `ProfileSetupStep.options` list as selectable cells.
/// Works for both single-select steps (`isSelected` + `onSelect`) and multi-select steps
/// (`isSelected` checks membership, `onSelect` toggles) — the parent view model owns that distinction.
struct SelectOptionsStepView: View {
    let options: [ProfileSetupOption]
    let isSelected: (String) -> Bool
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.value) { option in
                ProfileSetupOptionCell(title: option.label, isSelected: isSelected(option.value)) {
                    onSelect(option.value)
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
    }
}

//
//  CalendarPickerView.swift
//  Taichi
//

import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    var onConfirm: (Date) -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Asset.Color.mainColor.color)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "vi_VN"))

            Button {
                onConfirm(selectedDate)
            } label: {
                Text("Confirm")
                    .font(FontFamily.Inter.bold.font(size: Layout.Text.body))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.m)
                    .background(Asset.Color.mainColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.xxxl))
            }
        }
        .padding(Layout.Spacing.m)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
        .padding(.horizontal, Layout.Spacing.m)
    }
}

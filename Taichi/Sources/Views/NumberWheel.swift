//
//  NumberWheel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI
import UIKit

/// A single snapping number column for the reminder time picker.
///
/// `Picker(.wheel)` renders its own tinted selection bar and gives no control over per-row
/// colour, which the design needs (`#CCCCCC` idle, bold `#FF8D76` on the centre row). Wrapping
/// `UIPickerView` keeps the snapping behaviour while letting each row draw itself; the centre
/// highlight is drawn by the caller so it can span both columns as one rounded row.
struct NumberWheel: UIViewRepresentable {
    let values: [Int]
    @Binding var selection: Int
    /// How each value is drawn. Defaults to the zero-padded two digits the time picker wants.
    var format: (Int) -> String = { String(format: "%02d", $0) }
    /// Rows shown at once, centre row selected. The reminder picker shows five; option lists
    /// such as the rest timer show three.
    var visibleRows: CGFloat = 5

    static let rowHeight: CGFloat = 44

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        picker.setContentHuggingPriority(.defaultLow, for: .horizontal)

        if let index = values.firstIndex(of: selection) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self

        guard let index = values.firstIndex(of: selection) else { return }
        if picker.selectedRow(inComponent: 0) != index {
            picker.selectRow(index, inComponent: 0, animated: true)
        }
        // The centre row changed appearance, so every visible label has to be redrawn.
        picker.reloadComponent(0)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// `UIPickerView` has no useful intrinsic width, so without this it falls back to UIKit's
    /// default (~320pt) and two columns side by side overflow the sheet's width entirely.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIPickerView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width, height: Self.rowHeight * visibleRows)
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: NumberWheel

        init(_ parent: NumberWheel) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            NumberWheel.rowHeight
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let isSelected = pickerView.selectedRow(inComponent: component) == row

            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.text = parent.format(parent.values[row])
            label.font = UIFont(
                name: isSelected ? FontFamily.Inter.bold.name : FontFamily.Inter.medium.name,
                size: 22
            )
            label.textColor = isSelected
                ? UIColor(Asset.Color.mainColor.color)
                : UIColor(Asset.Color.gray.color)
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selection = parent.values[row]
            pickerView.reloadComponent(component)
        }
    }
}

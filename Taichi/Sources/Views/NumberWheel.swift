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
    /// Height of one row. The reminder picker and the in-session sheet use the default; the
    /// Profile duration sheets are drawn with taller 52pt rows.
    var rowHeight: CGFloat = NumberWheel.rowHeight
    /// Whether rows off the centre are bold too (the duration sheets draw every row Inter 700).
    var boldIdleRows = false

    static let rowHeight: CGFloat = 44

    func makeUIView(context: Context) -> UIPickerView {
        let picker = ClearSelectionPickerView()
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

        // Only act on a `selection` that changed from outside the wheel. A parent that re-renders
        // often (the in-session settings sheet observes the music player, which ticks 4x a second)
        // calls this mid-drag, when `selection` still holds the old value because it is only written
        // once the wheel settles -- forcing the picker back to it snapped every scroll back to the
        // number the sheet opened on.
        guard context.coordinator.lastSelection != selection else { return }
        context.coordinator.lastSelection = selection

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
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width, height: rowHeight * visibleRows)
    }

    /// `UIPickerView` draws its own translucent, inset selection bar. The callers draw the centre
    /// highlight themselves (one rounded `rowSelected` row), so the system bar stacked on top of it
    /// as a second, slightly different band. Clearing it leaves only the caller's row.
    private final class ClearSelectionPickerView: UIPickerView {
        override func layoutSubviews() {
            super.layoutSubviews()
            // The selection bar is the picker's second subview (iOS 14+); matching on the class
            // name as well keeps this working if that order ever changes.
            for (index, subview) in subviews.enumerated()
            where index == 1 || String(describing: type(of: subview)).contains("Selection") {
                subview.backgroundColor = .clear
            }
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: NumberWheel
        /// The last `selection` the wheel and its binding agreed on -- what `updateUIView` compares
        /// against to tell an outside change from a redundant re-render.
        var lastSelection: Int

        init(_ parent: NumberWheel) {
            self.parent = parent
            self.lastSelection = parent.selection
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            parent.rowHeight
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let isSelected = pickerView.selectedRow(inComponent: component) == row

            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.text = parent.format(parent.values[row])
            label.font = UIFont(
                name: isSelected || parent.boldIdleRows ? FontFamily.Inter.bold.name : FontFamily.Inter.medium.name,
                size: 22
            )
            label.textColor = isSelected
                ? UIColor(Asset.Color.mainColor.color)
                : UIColor(Asset.Color.gray.color)
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            lastSelection = parent.values[row]
            parent.selection = parent.values[row]
            pickerView.reloadComponent(component)
        }
    }
}

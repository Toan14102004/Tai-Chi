//
//  TextFormatTab.swift
//  Taichi
//
//  Created by Toan Nguyen on 10/13/25.
//

import Foundation

// MARK: - Text Format Tab

enum TextFormatTab: Int, CaseIterable {
    case textColor = 0
    case background = 1
    case alignment = 2

    var title: String {
        switch self {
        case .textColor:
            "Text Color"
        case .background:
            "Background"
        case .alignment:
            "Alignment"
        }
    }
}

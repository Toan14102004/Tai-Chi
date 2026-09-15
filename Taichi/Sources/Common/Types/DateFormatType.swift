//
//  DateFormatType.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation
import SwiftUI

enum DateFormatType: String, CaseIterable, Codable {
    case european = "dd/MM/yyyy"
    case american = "MM/dd/yyyy"
    case iso = "yyyy/MM/dd"

    var title: LocalizedStringKey {
        switch self {
        case .european:
            "dd/MM/yyyy"
        case .american:
            "MM/dd/yyyy"
        case .iso:
            "yyyy/MM/dd"
        }
    }
}

enum TimeFormatType: String, CaseIterable, Codable {
    case h12 = "hh:mm a"
    case h24 = "HH:mm"

    var title: LocalizedStringKey {
        switch self {
        case .h12:
            "12 hour"
        case .h24:
            "24 hour"
        }
    }
}

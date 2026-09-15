//
//  DateStyle.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation

enum DateStyle: Codable, Equatable {
    case current
    case custom(Date)

    var value: Date {
        switch self {
        case .current:
            Date()
        case let .custom(date):
            date
        }
    }
}

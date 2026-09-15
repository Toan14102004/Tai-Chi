//
//  LoggerDate.swift
//
//
//
//

import Foundation

extension Date {
    static let formatterISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var formattedISO8601: String { Date.formatterISO8601.string(from: self) }
    var currentDate: String { Date.shortFormatter.string(from: self) }
}

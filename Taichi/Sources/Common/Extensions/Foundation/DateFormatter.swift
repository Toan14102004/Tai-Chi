//
//  DateFormatter.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation

extension DateFormatter {
    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    static let relativeDateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .full
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    static func timeString(_ seconds: Int) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60

        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        }
        return String(format: "%02i:%02i", minute, second)
    }

    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter
    }()
}

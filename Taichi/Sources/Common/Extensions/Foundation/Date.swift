//
//  Date.swift
//  Taichi
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

enum DateState: Equatable {
    case yesterday, today, tomorrow, daysAgo(Int), indays(Int)

    var lowercaseString: String {
        switch self {
        case .yesterday:
            "yesterday"
        case .today:
            "today"
        case .tomorrow:
            "tomorrow"
        case let .daysAgo(day):
            "\(-day) days ago"
        case let .indays(day):
            "in \(day) days"
        }
    }
}

extension Date {
    func safeISO8601Format() -> String {
        if #available(iOS 15.0, *) {
            return self.ISO8601Format()
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            return formatter.string(from: self)
        }
    }

    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func startOfMonth() -> Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.year, .month],
                from: Calendar.current.startOfDay(for: self)
            )
        ) ?? Date()
    }

    func endOfMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth()) ?? Date()
    }

    func startOfMonth(with index: Int) -> Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.year, .month],
                from: Calendar.current.date(byAdding: .month, value: index, to: Date()) ?? Date()
            )
        ) ?? Date()
    }

    func endOfMonth(with index: Int) -> Date {
        Calendar.current.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: startOfMonth(with: index)
        ) ?? Date()
    }

    func dayNumberOfWeek() -> Int {
        Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0
    }

    func toString(with format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX") // ensure consistent result
        return formatter.string(from: self)
    }

    func toString(with format: TimeFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX") // ensure consistent result
        return formatter.string(from: self)
    }

    func toUTCDateString(format: DateFormatType) -> String {
        let formater = DateFormatter()
        formater.timeZone = TimeZone(abbreviation: "UTC")
        formater.dateFormat = format.rawValue
        return formater.string(from: self)
    }

    func toLocalDateStr(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        let localDateString = dateFormatter.string(from: self)
        return localDateString
    }
}

// MARK: - Date static methods

extension DateFormatter {
    static var unitedStatesDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }

    static func unitedStatesDateFormatter(dateFormat: String) -> DateFormatter {
        let formatter = Self.unitedStatesDateFormatter
        formatter.dateFormat = dateFormat
        return formatter
    }

    static func differenceStartEndTime(startTime: String, endTime: String, format: DateFormatType) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let startTimeDate = dateFormatter.date(from: startTime),
              let endTimeDate = dateFormatter.date(from: endTime) else {
            return 0
        }

        if startTimeDate > endTimeDate {
            let calendar = Calendar.current
            if let nextDayEndTime = calendar.date(byAdding: .day, value: 1, to: endTimeDate) {
                let timeDifference = nextDayEndTime.timeIntervalSince(startTimeDate) / 3600.0
                return timeDifference
            }
        } else {
            let timeDifference = endTimeDate.timeIntervalSince(startTimeDate) / 3600.0
            return timeDifference
        }
        return 0
    }
}

extension Date {
    enum WeekDay: Int {
        case sunday = 1
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday

        var weekDayDisplay: String {
            switch self {
            case .sunday:
                "Sunday"
            case .monday:
                "Monday"
            case .tuesday:
                "Tuesday"
            case .wednesday:
                "Wednesday"
            case .thursday:
                "Thursday"
            case .friday:
                "Friday"
            case .saturday:
                "Saturday"
            }
        }
    }

    func getWeekDay() -> WeekDay {
        let calendar = Calendar.current
        let weekDay = calendar.component(Calendar.Component.weekday, from: self)
        return WeekDay(rawValue: weekDay)!
    }

    func toStringInUnitedStates(toFormat dateFormat: String) -> String {
        let formatter = DateFormatter.unitedStatesDateFormatter
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

extension Date {
    static func compareDateString(
        firstCompareDate: String,
        secondCompareDate: String,
        format: DateFormatType,
        isSameDate: Bool = false
    ) -> Bool {
        let timeFormatter = DateFormatter.unitedStatesDateFormatter(dateFormat: format.rawValue)
        guard let startTime = timeFormatter.date(from: firstCompareDate),
              let finishTime = timeFormatter.date(from: secondCompareDate) else {
            return false
        }
        if isSameDate {
            return startTime >= finishTime
        }
        return startTime > finishTime
    }
}

extension Date {
    static func combine(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var newComponents = DateComponents()
        newComponents.timeZone = .current
        newComponents.day = dateComponents.day
        newComponents.month = dateComponents.month
        newComponents.year = dateComponents.year
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        newComponents.second = timeComponents.second

        return calendar.date(from: newComponents)
    }

    func addingMinutes(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
}

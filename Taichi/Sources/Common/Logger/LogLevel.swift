//
//  LogLevel.swift
//
//
//
//

import Foundation

public enum LogLevel {
    case debug
    case warning
    case notice
    case error
}

public extension LogLevel {
    var symbol: String {
        switch self {
        case .debug:
            "DEBUG ✅"
        case .warning:
            "WARNING ⚠️"
        case .notice:
            "NOTICE 📣"
        case .error:
            "ERROR ❌"
        }
    }

    var description: String {
        switch self {
        case .debug:
            "DEBUG"
        case .warning:
            "WARNING"
        case .notice:
            "NOTICE"
        case .error:
            "ERROR"
        }
    }
}

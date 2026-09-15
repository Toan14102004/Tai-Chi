//
//  Logger.swift
//
//
//
//

import Foundation

public struct Logger {
    private init() {}

    private static let connector = " "
    private static let queue = DispatchQueue(label: "Taichi_Logger", qos: .background)

    public static var isDebug: Bool = true

    public static func log(
        level: LogLevel,
        useFullLog: Bool = true,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        messages: [Any]
    ) {
        guard isDebug else { return }

        queue.async {
            let date: String = Date().formattedISO8601

            let fullMessages = getFullMessage(from: messages)

            /// 2021-8-20 20:11:11 DEBUG ✅
            let headLine = "\(date) \(level.symbol)"

            let address = [getFileName("\(file)"), "\(function)", "line: \(line)"].joined(separator: connector)

            let logString = useFullLog

                ? [headLine, address, fullMessages].joined(separator: connector)

                : [headLine, fullMessages].joined(separator: connector)

            print(logString)
        }
    }

    static func getFullMessage(from objects: [Any]) -> String {
        var string = ""
        for element in objects.map({ "\($0)" }) {
            if string.isEmpty {
                string = element
            } else {
                string = string + " " + element
            }
        }

        return string
    }

    static func getFileName(_ url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

    public static func d(
        useFullLog: Bool = true,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        messages: Any...
    ) {
        log(
            level: .debug,
            useFullLog: useFullLog,
            file: file,
            function: function,
            line: line,
            messages: messages
        )
    }

    public static func w(
        useFullLog: Bool = true,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        messages: Any...
    ) {
        log(
            level: .warning,
            useFullLog: useFullLog,
            file: file,
            function: function,
            line: line,
            messages: messages
        )
    }

    public static func n(
        useSymbol _: Bool = true,
        useFullLog: Bool = true,
        useShortDate _: Bool = false,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        messages: Any...
    ) {
        log(
            level: .notice,
            useFullLog: useFullLog,
            file: file,
            function: function,
            line: line,
            messages: messages
        )
    }

    public static func e(
        useFullLog: Bool = true,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line,
        messages: Any...
    ) {
        log(
            level: .error,
            useFullLog: useFullLog,
            file: file,
            function: function,
            line: line,
            messages: messages
        )
    }
}

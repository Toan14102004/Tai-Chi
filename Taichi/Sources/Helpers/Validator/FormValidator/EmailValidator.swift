//
// Created by Shaban on 24/05/2021.
// Copyright (c) 2021 sha. All rights reserved.
//

import Combine
import Foundation

/// Use this validator to confirm whether an email address is valid or not.
public class EmailValidator: StringValidator {
    public var publisher: ValidationPublisher!
    public var subject: ValidationSubject = .init()
    public var onChanged: [OnValidationChange] = []
    let regex: NSRegularExpression

    public init(message: @autoclosure @escaping StringProducerClosure) {
        self.message = message

        do {
            self.regex = try NSRegularExpression(
                pattern: Regex.email.rawValue,
                options: .caseInsensitive
            )
        } catch {
            // Xử lý lỗi: in lỗi hoặc cung cấp giá trị mặc định
            print("Failed to initialize regex: \(error)")
            self.regex = NSRegularExpression() // Giá trị mặc định
        }
    }

    public let message: StringProducerClosure

    public var value: String? = ""

    public func validate() -> Validation {
        let patternValidator = PatternValidator(pattern: regex, message: self.message())
        patternValidator.value = value
        return patternValidator.validate()
    }

}

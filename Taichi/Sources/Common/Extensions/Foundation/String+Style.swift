//
//  String+Style.swift
//  Taichi
//
//  Created by Toan Nguyen on 8/9/25.
//

import Foundation

@MainActor
public extension String {
    private static var markdownOptions = AttributedString.MarkdownParsingOptions(
        allowsExtendedAttributes: false,
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible,
        languageCode: nil
    )

    static func markdownStyler(text: String) -> AttributedString {
        if let attributed = try? AttributedString(markdown: text, options: String.markdownOptions) {
            attributed
        } else {
            AttributedString(stringLiteral: text)
        }
    }

    func styled(using styler: (String) -> AttributedString) -> AttributedString {
        styler(self)
    }
}

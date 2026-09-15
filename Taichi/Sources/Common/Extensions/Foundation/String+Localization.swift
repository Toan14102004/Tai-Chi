//
//  String+Localization.swift
//  Taichi
//
//  Created by Assistant on 9/23/25.
//

import Foundation
import SwiftUI

extension String {
    /// Converts a dynamic string (e.g. from a model) into a LocalizedStringKey
    /// so `Text(...)` re-localizes and updates when the app locale changes.
    var localizedKey: LocalizedStringKey { LocalizedStringKey(self) }

    /// Converts a localization key to its localized string value
    /// for use in TextField bindings - uses app's current language
    var localizedString: String {
        let currentLanguage = LanguageManager.shared.currentLanguageCode
        return localizedString(for: currentLanguage)
    }

    /// Converts a localization key to its localized string value for a specific language.
    ///
    /// Resolves the `.lproj` bundle straight from the language code rather than a hardcoded
    /// list -- every language the app ships (see the project's `knownRegions`) then works
    /// without this needing to be kept in sync. A regional code falls back to its base
    /// language ("pt-BR" -> "pt"), and English resolves to the key itself, which is the
    /// source text, since the development language has no `.lproj` of its own.
    private func localizedString(for languageCode: String) -> String {
        let baseCode = languageCode.split(separator: "-").first.map(String.init) ?? languageCode

        for code in [languageCode, baseCode] {
            guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
                  let bundle = Bundle(path: path)
            else { continue }
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }

        return NSLocalizedString(self, comment: "")
    }
}

//
//  LanguageManager.swift
//  Taichi
//
//  Created by Assistant on 8/9/25.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLocale: Locale
    @Published var currentLanguageCode: String = ""

    private init() {
        currentLanguageCode = "en"
        currentLocale = Locale.current
    }
    
    func initialize(savedLanguageCode: String) {
        if savedLanguageCode.isEmpty {
            currentLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
            currentLocale = Locale.current
        } else {
            currentLanguageCode = savedLanguageCode
            currentLocale = Locale(identifier: savedLanguageCode)
        }
    }
    
    func changeLanguage(_ languageCode: String) {
        currentLanguageCode = languageCode
        currentLocale = Locale(identifier: languageCode)
        
        // Trigger UI refresh
        objectWillChange.send()
    }
}

//
//  Helpers.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/2/25.
//

import Combine
import Foundation
import SwiftUI

extension String {
//    func localized(_ locale: Locale) -> String {
//        let localeId = locale.shortIdentifier
//        guard let path = Bundle.main.path(forResource: localeId, ofType: "lproj"),
//            let bundle = Bundle(path: path) else {
//            return NSLocalizedString(self, comment: "")
//        }
//        return bundle.localizedString(forKey: self, value: nil, table: nil)
//    }
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}

extension Locale {
    static var backendDefault: Locale {
        Locale(identifier: "en")
    }

    var shortIdentifier: String {
        String(identifier.prefix(2))
    }
}

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: true
        case .failure: false
        }
    }
}

// MARK: - View Inspection helper

final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

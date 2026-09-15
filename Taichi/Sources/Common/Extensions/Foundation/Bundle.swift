//
//  Bundle.swift
//  Taichi
//
//  Created by Toan Nguyen on 27/6/25.
//

import Foundation

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

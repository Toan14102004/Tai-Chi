//
//  FileError.swift
//  Taichi
//
//  Created by Toan Nguyen on 17/3/25.
//

import Foundation

enum FileError: Error, LocalizedError {
    case securityScopeAccessFailed
    case notDirectory
    case itemNotFound
    case fileModelCreationFailed(url: URL)
    case unowned(error: Error)

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            "Item not found"
        case .securityScopeAccessFailed:
            "Failed to access security scoped resource"
        case .notDirectory:
            "Parent is not a directory"
        case let .fileModelCreationFailed(url):
            "Failed to create File at URL: \(url.absoluteString)"
        case let .unowned(error):
            "File error: \(error.localizedDescription)"
        }
    }
}

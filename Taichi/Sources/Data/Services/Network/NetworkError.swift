//
//  NetworkError.swift
//  Taichi
//
//  Created by Toan Nguyen on 27/6/25.
//

import Foundation

// MARK: - Network Error

enum NetworkError: Error, LocalizedError {
    case networkError(Error)
    case serverError(Int, String)
    case decodingError(Error)
    case encodingError(Error)
    case invalidURL
    case noData
    case unauthorized
    case tokenExpired
    case invalidToken
    case tokenRefreshFailed
    case timeout
    case unknownError
    case notFound

    var errorDescription: String? {
        switch self {
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case let .serverError(code, message):
            message
        case let .decodingError(error):
            "Decoding error: \(error.localizedDescription)"
        case let .encodingError(error):
            "Encoding error: \(error.localizedDescription)"
        case .invalidURL:
            "Invalid URL"
        case .noData:
            "No data received"
        case .unauthorized:
            "Unauthorized access"
        case .tokenExpired:
            "Token has expired"
        case .invalidToken:
            "Invalid token"
        case .tokenRefreshFailed:
            "Failed to refresh token"
        case .timeout:
            "Request timed out"
        case .unknownError:
            "Unknown error occurred"
        case .notFound:
            "Not found"
        }
    }
}

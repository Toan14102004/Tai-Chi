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
            "Decoding error: \(Self.decodingDetail(error))"
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

    /// `DecodingError.localizedDescription` bridges to a fixed NSCocoaErrorDomain string --
    /// "The data couldn't be read because it isn't in the correct format" -- for every one of its
    /// cases, so it never actually says which field broke. Read the case directly instead so the
    /// error shown to the user (and reported back) names the exact key and reason.
    private static func decodingDetail(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else { return error.localizedDescription }

        switch decodingError {
        case let .keyNotFound(key, context):
            return "missing key '\(key.stringValue)' at \(path(context))"
        case let .typeMismatch(type, context):
            return "expected \(type) at \(path(context)) -- \(context.debugDescription)"
        case let .valueNotFound(type, context):
            return "missing value for \(type) at \(path(context))"
        case let .dataCorrupted(context):
            return "corrupted data at \(path(context)) -- \(context.debugDescription)"
        @unknown default:
            return decodingError.localizedDescription
        }
    }

    private static func path(_ context: DecodingError.Context) -> String {
        context.codingPath.isEmpty ? "<root>" : context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}

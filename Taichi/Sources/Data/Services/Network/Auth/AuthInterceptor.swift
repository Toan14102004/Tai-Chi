//
//  AuthInterceptor.swift
//  Taichi
//
//  Created by Toan Nguyen on 12/12/24.
//

import Alamofire
import CommonCrypto
import Foundation
import UIKit

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    @Injected var localStorageService: LocalStorageService

    private let userAgent: String

    init() {
        let device = UIDevice.current
        let osVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")

        userAgent =
            "Mozilla/5.0 (\(device.model); CPU iPhone OS \(osVersion) like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Mobile/15E148"
    }

    func adapt(
        _ urlRequest: URLRequest,
        for _: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var urlRequest = urlRequest

        // Every /v1 endpoint identifies the user by this header.
        urlRequest.setValue(localStorageService.deviceId, forHTTPHeaderField: "deviceId")

        // Security & Fingerprinting headers
        urlRequest.setValue("ios", forHTTPHeaderField: "x-platform")
        urlRequest.setValue(generateDeviceId(), forHTTPHeaderField: "x-device-id")
        urlRequest.setValue(TimeZone.current.identifier, forHTTPHeaderField: "x-timezone")
        urlRequest.setValue(getScreenResolution(), forHTTPHeaderField: "x-screen-resolution")
        urlRequest.setValue(getAppVersion(), forHTTPHeaderField: "x-app-version")

        // Advanced fingerprinting (simplified versions)
        urlRequest.setValue(generateCanvasFingerprint(), forHTTPHeaderField: "x-canvas-fingerprint")
        urlRequest.setValue(generateWebGLFingerprint(), forHTTPHeaderField: "x-webgl-fingerprint")
        urlRequest.setValue(generateHardwareFingerprint(), forHTTPHeaderField: "x-hardware-fingerprint")
        urlRequest.setValue(generateSessionId(), forHTTPHeaderField: "x-session-id")

        completion(.success(urlRequest))
    }

    // MARK: - Helper Methods

    private func getModelIdForEndpoint(_ path: String) -> String {
        if path.contains("generate-image") {
            "imagen-3.0-generate-002"
        } else {
            "gemini-2.0-flash"
        }
    }

    private func generateDeviceId() -> String {
        let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let combined = "\(identifierForVendor)_\(deviceModel)_\(systemVersion)"
        return sha256(combined)
    }

    private func getScreenResolution() -> String {
        let screen = UIScreen.main
        let scale = screen.scale
        let size = screen.bounds.size
        return "\(Int(size.width * scale))x\(Int(size.height * scale))"
    }

    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func generateCanvasFingerprint() -> String {
        // Simplified canvas fingerprint based on device characteristics
        let device = UIDevice.current
        let combined = "\(device.model)_\(device.systemVersion)_canvas"
        return sha256(combined).prefix(16).description
    }

    private func generateWebGLFingerprint() -> String {
        // Simplified WebGL fingerprint based on device characteristics
        let device = UIDevice.current
        let combined = "\(device.model)_\(device.systemVersion)_webgl"
        return sha256(combined).prefix(16).description
    }

    private func generateHardwareFingerprint() -> String {
        // Hardware fingerprint based on device info
        let device = UIDevice.current
        let combined = "\(device.model)_\(device.systemVersion)_\(ProcessInfo.processInfo.processorCount)"
        return sha256(combined)
    }

    private func generateSessionId() -> String {
        // Generate or retrieve session ID
        let key = "app_session_id"
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: key)
            return newId
        }
    }

    private func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}

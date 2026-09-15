//
//  NetworkMonitor.swift
//  Taichi
//

import Combine
import Foundation
import Network

/// Tracks device-level connectivity (Wi-Fi/cellular reachability) so the app can show
/// `NoInternetView` instead of leaving every screen stuck on a request that will never complete.
/// This is separate from `NetworkError` -- that reports a single request's outcome (including
/// server-side failures like a 504), while this reports whether the device has a route to the
/// internet at all.
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.taichi.networkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    /// `NWPathMonitor` already pushes updates as connectivity changes; this exists for the "Try
    /// again" button so tapping it reflects the current path immediately instead of waiting on
    /// the next system callback.
    func recheck() {
        let path = monitor.currentPath
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = path.status == .satisfied
        }
    }
}

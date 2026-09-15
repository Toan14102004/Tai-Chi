//
//  OnDemandResourceService.swift
//  Taichi
//
//  Created by Assistant on 10/16/25.
//

import Combine
import Foundation
import UIKit

final class OnDemandResourceService: Service {
    // MARK: - Service

    var shouldAutostart: Bool { true }

    private let cancelBag = CancelBag()
    
    func start() {
        let tag: OnDemandResourceTag = .location
        fetch(tags: tag)
            .sink { completion in
                switch completion {
                case .finished:
                    print("[ODR] Finished fetching resources for 'location'")
                case let .failure(error):
                    print("[ODR] Failed fetching resources for 'location': \(error)")
                }
            } receiveValue: { }
            .store(in: cancelBag)
    }

    func stop() {
        // Cancel and end all active requests
        for (key, request) in activeRequests {
            request.progress.cancel()
            request.endAccessingResources()
            activeRequests.removeValue(forKey: key)
        }
    }

    // MARK: - Public API

    func fetch(tags: OnDemandResourceTag, priority: Double = 1.0) -> AnyPublisher<Void, OnDemandResourceError> {
        let key = tags.normalizedKey
        if let existing = activeRequests[key] {
            existing.loadingPriority = priority
            return Future { promise in
                existing.beginAccessingResources { error in
                    if let error { promise(.failure(.system(error))) }
                    else { promise(.success(())) }
                }
            }
            .eraseToAnyPublisher()
        }

        let request = NSBundleResourceRequest(tags: tags.strings)
        request.loadingPriority = priority
        activeRequests[key] = request

        return Future { [weak self] promise in
            request.beginAccessingResources { error in
                if let error {
                    self?.activeRequests.removeValue(forKey: key)
                    promise(.failure(.system(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func progressPublisher(for tags: OnDemandResourceTag) -> AnyPublisher<Double, Never> {
        let key = tags.normalizedKey
        guard let request = activeRequests[key] else {
            return Just(0.0).eraseToAnyPublisher()
        }

        // KVO publisher for Progress.fractionCompleted
        return request.progress.publisher(for: \Progress.fractionCompleted)
            .removeDuplicates()
            .map { min(max($0, 0.0), 1.0) }
            .eraseToAnyPublisher()
    }

    func endAccessing(tags: OnDemandResourceTag) {
        let key = tags.normalizedKey
        guard let request = activeRequests[key] else { return }
        request.endAccessingResources()
        activeRequests.removeValue(forKey: key)
    }

    // MARK: - Private

    private var activeRequests: [Set<String>: NSBundleResourceRequest] = [:]
}

// MARK: - Error

enum OnDemandResourceError: Error {
    case system(Error)
}




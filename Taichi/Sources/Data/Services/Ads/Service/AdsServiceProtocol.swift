//
//  AdsServiceProtocol.swift
//
//  Created by Toan Nguyen on 9/24/25.
//

import Foundation

/// Lightweight representation required by services; avoids tight coupling.
protocol AdPlacementRepresentable {
    var id: String { get }
    var isEnabled: Bool { get }
}

/// A common protocol implemented by all ad services to unify management.
protocol AdService: AnyObject {
    /// Whether this ad service can operate under current conditions
    /// (e.g., ads enabled, subscription status, placement enabled).
    func canShow(adPlacement: AdPlacementRepresentable) -> Bool

    /// Preloads an ad for the given placement if supported by the service.
    /// If `adPlacementHigh` is provided and enabled, it should be preferred, with
    /// fallback to `adPlacement` when appropriate.
    func load(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?)

    /// Attempts to show an ad for the given placement using any internally loaded ad state.
    /// Services that need additional parameters may provide their own overloads.
    /// If `adPlacementHigh` is provided and enabled, it should be preferred, with
    /// fallback to `adPlacement` when appropriate.
    func show(adPlacement: AdPlacementRepresentable, adPlacementHigh: AdPlacementRepresentable?)
}

extension AdService {
    func load(adPlacement: AdPlacementRepresentable, adPlacementHigh _: AdPlacementRepresentable?) {
        // default to just loading the base placement; specific services may override
        _ = canShow(adPlacement: adPlacement)
    }

    func show(adPlacement _: AdPlacementRepresentable, adPlacementHigh _: AdPlacementRepresentable?) {
        // default no-op
    }
}

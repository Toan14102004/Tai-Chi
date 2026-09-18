//
//  AppFlags.swift
//  Taichi
//
//  Created by Toan Nguyen on 22/8/26.
//

import Foundation

/// Build-time switches for the two monetization surfaces.
///
/// Version 1 ships free: no ads, no paywall, every workout unlocked. To turn monetization back
/// on in a later version, flip the two constants below and rebuild — nothing else needs editing,
/// because every ad and IAP surface is gated through this type rather than checked in place.
///
/// These are deliberately `let` constants, not the `KeychainStorage`/`LocalStorageService` values
/// the ad services also read: those persist across launches and can be rewritten at runtime,
/// which is the wrong shape for a release switch. The stored values still apply on top when
/// monetization is on, so an individual placement can still be disabled without a build.
enum AppFlags {

    // MARK: - The two switches to flip for version 2

    /// Ships every ad surface: native, banner, interstitial, rewarded and app-open.
    private static let adsShipped = false

    /// Ships in-app purchases: the paywall, every entry point into it, and the premium upsell UI.
    private static let iapShipped = false

    // MARK: - What the app reads

    /// Ads are on only when this version ships them *and* the stored placement switch allows it,
    /// so the existing runtime toggle keeps working once ads are shipped again.
    static var adsEnabled: Bool { adsShipped && KeychainStorage.shared.adsEnabled }

    /// While this is off, `SubscriptionManager.isSubscribed` reports `true`, which is what hides
    /// the upsell everywhere and grants free access to the otherwise locked Discover workouts.
    static var iapEnabled: Bool { iapShipped }

    // MARK: - Progress tab manual activity log

    /// `/activities`, `/activity-categories` and their create/update/delete counterparts 404 as
    /// of 2026-09-14 -- the backend replaced them with `GET /v1/users/progress`, which only
    /// reports Tai Chi workout attempts, not free-form logged activities (no categories, no
    /// create/update/delete). Flip this back on once the backend ships a replacement; until then
    /// the Progress tab's "Activities" list and its "Add Activity" entry point stay hidden rather
    /// than showing a permanently-empty list or a save that always fails.
    static let manualActivityLoggingEnabled = false
}

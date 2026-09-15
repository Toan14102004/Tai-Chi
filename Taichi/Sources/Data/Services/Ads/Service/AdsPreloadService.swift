//
//  AdsPreloadService.swift
//  Taichi
//
//  Created by AI Assistant on 18/6/25.
//

import Foundation
import GoogleMobileAds

class AdsPreloadService: Service {
    @Injected var localStorageService: LocalStorageService
    @Injected var keychainStorage: KeychainStorage
    
    public enum AdsPreloadKey: String, CaseIterable {
        case language
        case languageClick
        case onboarding1
        case onboarding3
        case profileSetupCompact
        case profileSetupMedium
case practiceCompact
        case discoverCompact
        case discoverCompactSecondary
        case profileMedium
        
        var adChoicePosition: AdChoicesPosition {
            switch self {
            default: .topRightCorner
            }
        }
    }
    
    /// Configuration for each ad key: (placement, placementHigh)
    private var adConfigurations: [AdsPreloadKey: (AdPlacement, AdPlacement?)] = [:]
    
    var shouldAutostart: Bool = true
    var didConfigure: Bool = false
    private var preloadedAds: [AdsPreloadKey: NativeAdViewModel] = [:]
    
    // Cache for list ads
    private var listAdsCache: [String: NativeAdViewModel] = [:]
    
    func start() {
        // Listen for remote config ready notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appConfigReady),
            name: .appConfigReady,
            object: nil
        )
    }
    
    @objc private func appConfigReady() {
        // Only configure ad placements after remote config is ready, do NOT load ads yet
        guard !didConfigure else { return }
        didConfigure = true
        configureAdPlacements()
    }
    
    func stop() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configuration Methods (No auto-loading)
    
    private func configureAdPlacements() {
        // Configure native language ads (only register, do not load)
        let languageAd = localStorageService.foodNativeLanguage
        let languageAdHight = localStorageService.foodNativeLanguageHight
        adConfigurations[.language] = (languageAd, languageAdHight)
        
        // Configure native language click ads (only register, do not load)
        let languageClickAd = localStorageService.foodNativeLanguageClick
        let languageClickAdHight = localStorageService.foodNativeLanguageClickHight
        adConfigurations[.languageClick] = (languageClickAd, languageClickAdHight)

        // Configure native Profile Setup ads (only register, do not load)
        adConfigurations[.profileSetupCompact] = (localStorageService.profileSetupCompactAd, nil)
        adConfigurations[.profileSetupMedium] = (localStorageService.profileSetupMediumAd, nil)

// Configure native Practice ads (only register, do not load)
        adConfigurations[.practiceCompact] = (localStorageService.practiceCompactAd, nil)

        // Configure native Discover ads (only register, do not load)
        adConfigurations[.discoverCompact] = (localStorageService.discoverCompactAd, nil)
        adConfigurations[.discoverCompactSecondary] = (localStorageService.discoverCompactSecondaryAd, nil)
        // Configure native Profile tab ads (only register, do not load)
        adConfigurations[.profileMedium] = (localStorageService.profileMediumAd, nil)
    }
    
    // MARK: - Public Methods
    
    /// Register a custom ad configuration for a key
    func registerAdConfiguration(
        for key: AdsPreloadKey, placement: AdPlacement, placementHigh: AdPlacement? = nil
    ) {
        adConfigurations[key] = (placement, placementHigh)
    }
    
    /// Get or create the ViewModel for a key. If the ViewModel doesn't exist, create it from configuration.
    func getPreloadedAd(for key: AdsPreloadKey) -> NativeAdViewModel? {
        // If already have a ViewModel, return it
        if let existingViewModel = preloadedAds[key] {
            return existingViewModel
        }
        
        // If not, try to create from configuration
        guard let config = adConfigurations[key] else {
            print("[AdsPreloadService] No configuration found for key: \(key)")
            return nil
        }
        
        let (placement, placementHigh) = config
        guard placement.isEnabled else {
            print("[AdsPreloadService] Ad placement is disabled for key: \(key)")
            return nil
        }
        
        // Create ViewModel but do NOT load yet
        let viewModel = NativeAdViewModel(
            adPlacement: placement,
            adPlacementHight: placementHigh,
            adChoicesPosition: key.adChoicePosition
        )
        preloadedAds[key] = viewModel
        return viewModel
    }
    
    /// Load ad for a key if not already loaded. Call this when the view needs the ad.
    func loadAdIfNeeded(for key: AdsPreloadKey) {
        guard let viewModel = getPreloadedAd(for: key) else {
            print("[AdsPreloadService] Cannot load ad for key: \(key) - no configuration or disabled")
            return
        }
        
        // Only load if not already loaded and not currently loading
        if viewModel.nativeAd == nil && !viewModel.isLoading {
            print("[AdsPreloadService] Loading ad for key: \(key)")
            viewModel.refreshAd()
        }
    }
    
    /// Preload ad immediately (legacy method for backward compatibility)
    func preloadAd(key: AdsPreloadKey, placement: AdPlacement, placementHigh: AdPlacement? = nil) {
        if placement.isEnabled {
            let viewModel = NativeAdViewModel(
                adPlacement: placement,
                adPlacementHight: placementHigh,
                adChoicesPosition: key.adChoicePosition
            )
            preloadedAds[key] = viewModel
            viewModel.refreshAd()
        }
    }
    
    func refreshAd(for key: AdsPreloadKey) {
        preloadedAds[key]?.refreshAd()
    }
}

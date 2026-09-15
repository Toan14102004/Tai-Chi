//
//  PreloadedNativeAdsView.swift
//  Taichi
//
//  Created by AI Assistant on 18/6/25.
//

import Combine
import GoogleMobileAds
import SwiftUI

struct PreloadedNativeAdsView: View {
  @EnvironmentObject var subscriptionManager: SubscriptionManager
  @Injected var keychainStorage: KeychainStorage
  @Injected var adsPreloadService: AdsPreloadService

  let adKey: AdsPreloadService.AdsPreloadKey
  let style: NativeAdViewStyle
  let height: CGFloat
  let showBorder: Bool
  let index: Int?

  // Internal observation wrapper
  @StateObject private var adObserver = AdObserver()

  init(
    adKey: AdsPreloadService.AdsPreloadKey,
    style: NativeAdViewStyle,
    height: CGFloat,
    showBorder: Bool = true,
    index: Int? = nil
  ) {
    self.adKey = adKey
    self.style = style
    self.height = height
    self.showBorder = showBorder
    self.index = index
  }

  private var targetViewModel: NativeAdViewModel? {
    return adsPreloadService.getPreloadedAd(for: adKey)
  }

  var body: some View {
    VStack {
      if subscriptionManager.hidesAds || !AppFlags.adsEnabled {
        EmptyView()
      } else if let viewModel = targetViewModel, let nativeAd = adObserver.nativeAd {
        let _ = print("[PreloadedNativeAdsView] [\(adKey)] Showing loaded ad (Observer)")
        // Construct view with the view model that has the ad
        if let viewModel = targetViewModel {
          NativeAdsSwiftUIView(nativeViewModel: viewModel, style: style)
            .frame(height: height)
            .background(Asset.Color.white.color)
            .cornerRadius(radius: Layout.CornerRadius.medium, corners: .allCorners)
            .overlay {
              RoundedRectangle(cornerRadius: Layout.CornerRadius.medium)
                .stroke(Color(hex: "#BFC6D7").opacity(0.25), lineWidth: showBorder ? 1 : 0)
            }
        }
      } else if adObserver.isLoading {
        let _ = print("[PreloadedNativeAdsView] [\(adKey)] Ad is loading...")
        VStack {
          ActivityIndicatorView(isVisible: .constant(true), type: .default(count: 8))
            .foregroundColor(Asset.Color.primary.color.opacity(0.5))
            .frame(
              width: Layout.Spacing.xxl,
              height: Layout.Spacing.xxl
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(.gray.opacity(0.5))
      } else {
        let _ = print("[PreloadedNativeAdsView] [\(adKey)] Ad nil and not loading -> EmptyView")
        EmptyView()
      }
    }
    .onAppear {
      // Trigger ad loading if needed
      adsPreloadService.loadAdIfNeeded(for: adKey)

      if let viewModel = targetViewModel {
        print(
          "[PreloadedNativeAdsView] [\(adKey)] Binding observer to ViewModel (Index: \(String(describing: index)))"
        )
        adObserver.bind(to: viewModel)

        if viewModel.nativeAd == nil && !viewModel.isLoading {
          print("[PreloadedNativeAdsView] [\(adKey)] Ad empty/not loading -> refreshing")
          viewModel.refreshAd()
        }
      } else {
        print("[PreloadedNativeAdsView] [\(adKey)] No ViewModel found in service")
      }
    }
  }
}

// Helper class to observe a specific NativeAdViewModel from the service
class AdObserver: ObservableObject {
  @Published var nativeAd: NativeAd?
  @Published var isLoading: Bool = false
  private var cancellables = Set<AnyCancellable>()

  func bind(to viewModel: NativeAdViewModel) {
    // Initial values
    self.nativeAd = viewModel.nativeAd
    self.isLoading = viewModel.isLoading

    // Clear previous subscriptions
    cancellables.removeAll()

    viewModel.$nativeAd
      .receive(on: RunLoop.main)
      .sink { [weak self] val in
        self?.nativeAd = val
      }
      .store(in: &cancellables)

    viewModel.$isLoading
      .receive(on: RunLoop.main)
      .sink { [weak self] val in
        self?.isLoading = val
      }
      .store(in: &cancellables)
  }
}

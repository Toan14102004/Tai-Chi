//
//  NativeAdsView.swift
//  ARDraw
//
//  Created by Toan Nguyen on 5/9/25.
//

import SwiftUI

struct CollapseAdsEmptyView: View {
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Injected var keychainStorage: KeychainStorage
    
    let adPlacement: AdPlacement
    let adPlacementHight: AdPlacement?
    let height: CGFloat
    @Binding var isVisible: Bool
    
    var body: some View {
        if !isVisible || subscriptionManager.hidesAds || !AppFlags.adsEnabled || (!adPlacement.isEnabled && !(adPlacementHight?.isEnabled ?? false)) {
            EmptyView()
        } else {
            VStack {}
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
    }
}

struct NativeAdsView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Injected var keychainStorage: KeychainStorage
    @StateObject private var nativeViewModel: NativeAdViewModel

    let adPlacement: AdPlacement
    let adPlacementHight: AdPlacement?
    let style: NativeAdViewStyle
    let height: CGFloat
    var onAdLoaded: Binding<Bool>?
    let isShowColorAtBottomSafeArea: Bool

    init(
        adPlacement: AdPlacement,
        adPlacementHight: AdPlacement? = nil,
        style: NativeAdViewStyle,
        height: CGFloat,
        onAdLoaded: Binding<Bool>? = nil,
        isShowColorAtBottomSafeArea: Bool = false
    ) {
        _nativeViewModel = StateObject(wrappedValue: NativeAdViewModel(adPlacement: adPlacement, adPlacementHight: adPlacementHight))
        self.style = style
        self.height = height
        self.adPlacement = adPlacement
        self.adPlacementHight = adPlacementHight
        self.onAdLoaded = onAdLoaded
        self.isShowColorAtBottomSafeArea = isShowColorAtBottomSafeArea
    }

    @State private var isCollapsed: Bool = false
    @State private var currentHeight: CGFloat = 0

    var body: some View {
        VStack {
            if subscriptionManager.hidesAds || !AppFlags.adsEnabled || (!adPlacement.isEnabled && !(adPlacementHight?.isEnabled ?? false)) {
                EmptyView()
            } else if nativeViewModel.nativeAd != nil {
                VStack (spacing: 0) {
                    NativeAdsSwiftUIView(nativeViewModel: nativeViewModel, style: style, onCollapse: {
                        withAnimation {
                            isCollapsed = true
                        }
                    })
                    .frame(height: isCollapsed ? height : calculateHeight())
                    .background(Asset.Color.white.color)
                    .cornerRadius(radius: Layout.CornerRadius.large, corners: isShowColorAtBottomSafeArea ? [.topLeft, .topRight] : .allCorners)
                    .overlay {
                        if !isShowColorAtBottomSafeArea {
                            RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                                .stroke(Color(hex: "#BFC6D7").opacity(0.25), lineWidth: 1)
                        }
                    }
                    
                    if isShowColorAtBottomSafeArea {
                        VStack { }
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .background(.white)
                    }
                }
            } else if nativeViewModel.isLoading {
                VStack {
                    ActivityIndicatorView(isVisible: .constant(true), type: .default(count: 8))
                        .foregroundColor(Asset.Color.gray.color.opacity(0.5))
                        .frame(
                            width: Layout.Spacing.xxl,
                            height: Layout.Spacing.xxl
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(.gray.opacity(0.5))
            } else {
                EmptyView()
            }
        }
        .onAppear {
            guard !subscriptionManager.hidesAds, AppFlags.adsEnabled, adPlacement.isEnabled else { return }
            if nativeViewModel.nativeAd == nil, !nativeViewModel.isLoading {
                nativeViewModel.refreshAd()
            }
        }
        .onChange(of: nativeViewModel.nativeAd) { newValue in
            onAdLoaded?.wrappedValue = newValue != nil
        }
        .onChange(of: nativeViewModel.isLoading) { newValue in
            if newValue {
                onAdLoaded?.wrappedValue = true
            } else if nativeViewModel.nativeAd == nil {
                onAdLoaded?.wrappedValue = false
            }
        }
    }
    
    private func calculateHeight() -> CGFloat {
        if case .collapse = style {
            // Estimate Expanded Height: Banner (60) + Media (Width * 0.56) + Margins
            // Since we can't easily access width here without GeometryReader, we can approximate or use a reasonable max.
            // However, a better approach for exact ratio is using .aspectRatio or letting it grow.
            // But preserving the existing API which uses .frame(height), we will estimate based on screen width padding.
            let screenWidth = UIScreen.main.bounds.width
            let mediaHeight = (screenWidth - 32) * 0.66 // Approx margins
            return height + mediaHeight + 24 // + Padding
        }
        return height
    }
}

#Preview {
    NativeAdsView(
        adPlacement: .init(id: "ca-app-pub-3940256099942544/4411468910", isEnabled: true),
        style: .large(),
        height: 300
    )
    .preview()
}

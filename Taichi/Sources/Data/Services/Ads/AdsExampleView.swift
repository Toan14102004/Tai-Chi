//
//  AdsExampleView.swift
//  ARDraw
//
//  Created by Toan Nguyen on 5/9/25.
//

import SwiftUI

struct AdsExampleView: View {
    @Injected var adMobManager: AdsManager
    @Injected var localStorageService: LocalStorageService

    var body: some View {
        VStack(spacing: 20) {
            
//            NativeAdsView(
//                adPlacement: localStorageService.gpsCameraNativeLanguage,
//                style: .large(),
//                height: 260
//            )
            
//            GeometryReader { proxy in
//                NativeAdsView(
//                    adPlacement: localStorageService.gpsCameraNativeLanguage,
//                    style: .fullScreen,
//                    height: proxy.size.height
//                )
//            }
            
            
            
//            BannerAdsView(adPlacement: localStorageService.bannerHome)
//
            NativeAdsView(adPlacement: .init(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true), style: .video, height: 260)
                .background(.gray)
            
//            Spacer()
//
//            NativeAdsView(adPlacement: localStorageService.gpsCameraNativeLanguage, style: .large(), height: 250)
//                .background(.gray)
//
//            NativeAdsView(adPlacement: .init(id: "ca-app-pub-3940256099942544/3986624511", isEnabled: true), style: .large(), height: 250)
//                .background(.gray)
            
//            NativeAdsView(adPlacement: localStorageService.gpsCameraNativeLanguage, style: .large(isFilled: false), height: 250)
//                .background(.gray)

//            Spacer()
//
//            // Buttons to test interstitial and rewarded ads
//            VStack(spacing: 16) {
//                Button("Show Interstitial (Default)") {
//                    showInterstitialAd()
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//                Button("Show Rewarded Ad") {
//                    showRewardedAd()
//                }
//                .padding()
//                .background(Color.orange)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//                Button("Show App Open Ad") {
//                    showAppOpenAd()
//                }
//                .padding()
//                .background(Color.purple)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding()
    }

    private func showInterstitialAd() {
        adMobManager.showInterstitialAd(
            adPlacement: .init(id: "ca-app-pub-5199643356270953/4972488326", isEnabled: true),
            onDismissed: {
                print("Interstitial dismissed")
            },
            onFailed: { error in
                print("Interstitial failed: \(error.localizedDescription)")
            },
            onShown: {
                print("Interstitial shown")
            }
        )
    }

    private func showRewardedAd() {
//        adMobManager.showRewardedAd(
//            adUnitID: AdMobManager.AdUnitIDs.rewarded
//        ) { reward in
//            print("Reward received: \(reward.rewardAmount) \(reward.rewardType)")
//        }
    }

    private func showAppOpenAd() {
        adMobManager.showAppOpenAd(adPlacement: .init(id: "ca-app-pub-5199643356270953/4063549576", isEnabled: true), adPlacementHight: nil)
    }
}

#Preview {
    AdsExampleView()
        .preview()
        .environmentObject(SubscriptionManager())
}

//
//  NativeAdViewStyle.swift
//
//
//  Created by minghui on 2023/6/15.
//

import GoogleMobileAds
import SwiftUI

public enum NativeAdViewStyle {
    case basic
    case banner
    case contentCard
    case fullScreen
    case large(isFilled: Bool = true)
    case largeGray
    case medium
    case mediumMedia
    case smallMedia
    case overlay
    case collapse
    case iconMedia
    case video

    var view: NativeAdView {
        switch self {
        case .basic:
            return makeNibView(name: "NativeAdView")
        case .banner:
            return NativeAdBannerView(frame: .zero)
        case .contentCard:
            return NativeAdContentCardView(frame: .zero)
        case .fullScreen:
            return NativeAdFullScreenView(frame: .zero)
        case .large(let isFilled):
            let largeView = NativeAdLargeView(frame: .zero)
            largeView.setButtonStyle(filled: isFilled)
            return largeView
        case .largeGray:
            return NativeAdLargeGrayView(frame: .zero)
        case .medium:
            return NativeAdMediumView(frame: .zero)
        case .mediumMedia:
            return NativeAdMediumMediaView(frame: .zero)
        case .smallMedia:
            return NativeAdSmallMediaView(frame: .zero)
        case .overlay:
            return NativeAdOverlayView(frame: .zero)
        case .collapse:
            return NativeAdCollapseView(frame: .zero)
        case .iconMedia:
            return NativeAdIconMediaView(frame: .zero)
        case .video:
            return NativeAdVideoView(frame: .zero)
        }
    }

    var height: CGFloat {
        switch self {
        case .basic:
            100
        case .banner:
            80
        case .contentCard:
            204
        case .fullScreen:
            UIScreen.main.bounds.height
        case .large:
            260
        case .largeGray:
            260
        case .medium:
            130
        case .mediumMedia: // not use
            150
        case .smallMedia:
            180
        case .overlay:
            180
        case .collapse:
            60
        case .iconMedia:
            220
        case .video:
            280
        }
    }

    func makeNibView(name: String) -> NativeAdView {
        let nib = UINib(nibName: name, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! NativeAdView
    }
}

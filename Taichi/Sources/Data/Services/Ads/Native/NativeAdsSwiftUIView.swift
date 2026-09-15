import GoogleMobileAds
import SwiftUI

public struct NativeAdsSwiftUIView: UIViewRepresentable {
    public typealias UIViewType = NativeAdView

    @ObservedObject var nativeViewModel: NativeAdViewModel
    var style: NativeAdViewStyle
    var onCollapse: (() -> Void)? = nil

    public init(nativeViewModel: NativeAdViewModel, style: NativeAdViewStyle = .basic, onCollapse: (() -> Void)? = nil) {
        self.nativeViewModel = nativeViewModel
        self.style = style
        self.onCollapse = onCollapse
    }

    public func makeUIView(context _: Context) -> NativeAdView {
        style.view
    }

    func removeCurrentSizeConstraints(from mediaView: UIView) {
        for constraint in mediaView.constraints {
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                mediaView.removeConstraint(constraint)
            }
        }
    }

    public func updateUIView(_ nativeAdView: NativeAdView, context _: Context) {
        if let collapseView = nativeAdView as? NativeAdCollapseView {
            collapseView.onCollapse = onCollapse
        }
        
        guard let nativeAd = nativeViewModel.nativeAd else { return }
        if let mediaView = nativeAdView.mediaView {
            mediaView.contentMode = .scaleAspectFit
            mediaView.clipsToBounds = true

            let aspectRatio = nativeAd.mediaContent.aspectRatio

            debugPrint("Google aspectRatio: \(aspectRatio), hasVideoContent: \(nativeAd.mediaContent.hasVideoContent)")

            if case .medium = style {
                removeCurrentSizeConstraints(from: mediaView)
                if aspectRatio > 0 {
                    if aspectRatio > 1 {
                        mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: aspectRatio)
                            .isActive = true
                    } else {
                        mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: 1).isActive = true
                    }
                } else {
                    mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: 16 / 9)
                        .isActive = true
                }
            }
        }

        // headline require
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

        // body
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        // icon
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = (nativeAd.icon == nil)

        // ratting
        let starRattingImage = imageOfStars(from: nativeAd.starRating)
        (nativeAdView.starRatingView as? UIImageView)?.image = starRattingImage
        nativeAdView.starRatingView?.isHidden = (starRattingImage == nil)

        // store
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        // price
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        // advertiser
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = (nativeAd.advertiser == nil)

        // button
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        // TODO: Update call to action
        if case .medium = style, let body = nativeAd.body, !body.isEmpty {
            nativeAdView.callToActionView?.isHidden = true
        }

        // Associate the native ad view with the native ad object. This is required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
}

extension NativeAdsSwiftUIView {
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }

        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}

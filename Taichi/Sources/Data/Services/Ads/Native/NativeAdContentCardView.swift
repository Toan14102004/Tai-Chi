//
//  NativeAdContentCardView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//
//  The in-feed ad card used by the Practice flow: square media on the left, headline and body to
//  its right, and a full-width gradient CTA underneath. `NativeAdBannerView` keeps the older
//  layout (CTA inline on the right) because the Profile Setup flow still uses it.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdContentCardView: NativeAdView {
    let adTag: PaddingLabel = .init(
        text: "Ad",
        font: .systemFont(ofSize: 10, weight: .semibold),
        textColor: Asset.Color.white.uiColor,
        textAlignment: .center
    )
    let headlineLabel = UILabel(
        text: "",
        font: .systemFont(ofSize: 15, weight: .bold),
        textColor: Asset.Color.textPrimary.uiColor
    )
    let bodyLabel = UILabel(
        text: "",
        font: .systemFont(ofSize: 13, weight: .regular),
        textColor: Asset.Color.textSecondary.uiColor
    )
    let callToActionButton = UIButton(
        title: "Install",
        titleColor: Asset.Color.white.uiColor,
        font: .boldSystemFont(ofSize: 15),
        backgroundColor: .clear,
        target: nil,
        action: nil
    )
    /// The square thumbnail is the ad's icon, not its media. A fixed-size square `MediaView` makes
    /// the AdMob native validator complain -- it checks the media view against the creative's own
    /// aspect ratio and minimum size -- while an icon is square by definition.
    let iconImageView = UIImageView()

    private let callToActionGradientLayer = AppGradient.makeCAGradientLayer()
    private static let iconSize: CGFloat = 90
    private static let ctaHeight: CGFloat = 44
    private static let ctaCornerRadius: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        headlineView = headlineLabel
        bodyView = bodyLabel
        iconView = iconImageView
        callToActionView = callToActionButton

        backgroundColor = Asset.Color.bgAds.uiColor

        adTag.topInset = 2
        adTag.bottomInset = 2
        adTag.leftInset = 6
        adTag.rightInset = 6
        adTag.backgroundColor = Asset.Color.mainColor.uiColor
        adTag.layer.cornerRadius = 4
        adTag.clipsToBounds = true
        adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")

        headlineLabel.numberOfLines = 2
        headlineLabel.lineBreakMode = .byTruncatingTail

        bodyLabel.numberOfLines = 3
        bodyLabel.lineBreakMode = .byTruncatingTail

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 12
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.constrainWidth(Self.iconSize)
        iconImageView.constrainHeight(Self.iconSize)

        callToActionButton.layer.cornerRadius = Self.ctaCornerRadius
        callToActionButton.clipsToBounds = true
        callToActionGradientLayer.cornerRadius = Self.ctaCornerRadius
        callToActionButton.layer.insertSublayer(callToActionGradientLayer, at: 0)

        let textStack = stack(headlineLabel, bodyLabel, UIView(), spacing: 4)
        let topRow = hstack(iconImageView, textStack, spacing: 12, alignment: .top)

        // The "Ad" label is a row of its own rather than a badge floating over the media: overlaying
        // it obscures an ad asset, which the AdMob native validator flags as an implementation issue.
        let attributionRow = hstack(adTag, UIView(), spacing: 0)

        let mainStack = stack(
            attributionRow,
            topRow,
            callToActionButton.withHeight(Self.ctaHeight),
            spacing: 10
        )
        addSubview(mainStack)
        mainStack.fillSuperview(padding: .init(top: 10, left: 12, bottom: 12, right: 12))

        let adChoicesContainer = AdChoicesView()
        adChoicesContainer.backgroundColor = .clear
        adChoicesContainer.clipsToBounds = true
        addSubview(adChoicesContainer)
        adChoicesContainer.anchor(
            top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,
            padding: .init(top: 4, left: 0, bottom: 0, right: 8),
            size: .init(width: 20, height: 20)
        )
        adChoicesView = adChoicesContainer
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        callToActionGradientLayer.frame = callToActionButton.bounds
    }
}

//
//  NativeAdLargeGrayView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/9/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdLargeGrayView: NativeAdView {
  // require
  let myMediaView = MediaView()
  let iconImageView = UIImageView()
  let headlineLabel = UILabel(
    text: "",
    font: .systemFont(ofSize: 15, weight: .medium),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 2
  )
  let adTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )

  // for web
  let advertiserLabel = UILabel(
    text: "",
    font: .systemFont(ofSize: 14, weight: .regular),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 1
  )
  let bodyLabel = UILabel(
    text: "",
    font: .systemFont(ofSize: 14, weight: .regular),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 3
  )

  // for app
  let callToActionButton = UIButton(
    title: "",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 14),
    backgroundColor: Asset.Color.primary.uiColor,
    target: nil,
    action: nil
  )
  let installButton = UIButton(
    title: "INSTALL",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 16),
    backgroundColor: Asset.Color.primary.uiColor,
    target: nil,
    action: nil
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  func setupViews() {
    // Configure icon view (logo)
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFill
    iconView = iconImageView

    // Configure media view (displayed above install button)
    myMediaView.translatesAutoresizingMaskIntoConstraints = false
    myMediaView.contentMode = .scaleAspectFit
    myMediaView.clipsToBounds = true
    // Default to 16:9 and cap height so total fits within 260
    let mediaAspect = myMediaView.heightAnchor.constraint(
      equalTo: myMediaView.widthAnchor, multiplier: 9.0 / 16.0)
    mediaAspect.priority = .defaultHigh
    mediaAspect.isActive = true
    myMediaView.heightAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
    mediaView = myMediaView

    headlineView = headlineLabel
    advertiserView = advertiserLabel
    bodyView = bodyLabel
    headlineLabel.numberOfLines = 2
    headlineLabel.lineBreakMode = .byTruncatingTail
    advertiserLabel.numberOfLines = 1
    advertiserLabel.lineBreakMode = .byTruncatingTail
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byTruncatingTail

    callToActionButton.layer.cornerRadius = 8
    callToActionButton.clipsToBounds = true
    callToActionView = callToActionButton

    // Configure install button
    installButton.layer.cornerRadius = 8
    installButton.clipsToBounds = true
    installButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    // Make button size fit its content and resist stretching
    installButton.setContentHuggingPriority(.required, for: .horizontal)
    installButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    let leftStack = stack(headlineLabel, advertiserLabel, bodyLabel, callToActionButton, spacing: 6)
      .withMargins(
        .init(
          top: 6,
          left: 0,
          bottom: 6,
          right: 8
        ))
    let topContent = hstack(iconImageView, leftStack, spacing: 8)

    // Media placed above a right-aligned install button
    let buttonRow = hstack(UIView(), installButton, spacing: 8)
    let mediaAndButton = stack(myMediaView, buttonRow, spacing: 8)
    // Main layout with media + install button at bottom
    let mainStack = stack(topContent, mediaAndButton, spacing: 8).withMargins(
      .init(
        top: 8,
        left: 8,
        bottom: 8,
        right: 8
      ))
    addSubview(mainStack)
    mainStack.fillSuperview()

    // AD Tag Label
    addSubview(adTag)
    adTag.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      adTag.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      adTag.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
      adTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 25),
      adTag.heightAnchor.constraint(equalToConstant: 15),
    ])

    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 4
    adTag.clipsToBounds = true
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")
    adTag.textColor = Asset.Color.black.uiColor

    // Set black background for the entire view
    backgroundColor = Asset.Color.black.uiColor
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

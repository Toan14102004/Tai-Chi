//
//  NativeAdVideoView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/12/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdVideoView: NativeAdView {
  // require
  let myMediaView = MediaView()
  let iconImageView = UIImageView()
  let headlineLabel = UILabel(
    text: "",
    font: FontFamily.Inter.bold.font(size: 16),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 1
  )
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)

  let adTag: PaddingLabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )

  // Call to Action Button
  let installButton = UIButton(
    title: "Open",
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
    // Set GADNativeAdView properties
    headlineView = headlineLabel
    iconView = iconImageView
    mediaView = myMediaView
    callToActionView = installButton
    bodyView = bodyLabel

    // 1. Setup Ad Tag (Absolute Top-Left)
    addSubview(adTag)
    adTag.topInset = 2
    adTag.bottomInset = 2
    adTag.leftInset = 4
    adTag.rightInset = 4
    adTag.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      adTag.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      adTag.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      adTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),
      adTag.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
    ])

    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = Layout.CornerRadius.medium
    adTag.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
    adTag.clipsToBounds = true
    adTag.textColor = Asset.Color.black.uiColor

    // Set black background for the entire view
    backgroundColor = Asset.Color.black.uiColor

    // 2. Setup Ad Choices (Absolute Top-Right)
    let adChoicesContainer = AdChoicesView()
    adChoicesContainer.backgroundColor = .clear
    addSubview(adChoicesContainer)
    adChoicesContainer.anchor(
      top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .zero,
      size: .init(width: 24, height: 24))
    self.adChoicesView = adChoicesContainer

    // 3. Layout Components
    headlineLabel.numberOfLines = 1

    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFill
    iconImageView.backgroundColor = .secondarySystemBackground
    iconImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    iconImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

    myMediaView.contentMode = .scaleAspectFill
    myMediaView.clipsToBounds = true
    myMediaView.layer.cornerRadius = 8
    myMediaView.backgroundColor = .secondarySystemBackground
    // Video ads usually benefit from 16:9 or similar. Increasing height to 160.
    myMediaView.heightAnchor.constraint(equalToConstant: 160).isActive = true

    installButton.layer.cornerRadius = 24
    installButton.clipsToBounds = true
    installButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

    // Header Row: Spacer (for AdTag) + Headline
    let headerRow = hstack(
      UIView().withWidth(48).withHeight(16),  // Spacer matching Icon width
      headlineLabel,
      UIView(),  // Spacer
      spacing: 12
    )

    // Body Row: Icon + Media
    // UPDATED: alignment .top instead of .center
    let bodyRow = hstack(iconImageView, myMediaView, spacing: 12, alignment: .top)

    // Main Stack
    let mainStack = stack(
      headerRow,
      bodyRow,
      installButton,
      spacing: 12
    )
    // Add margins
    mainStack.withMargins(.init(top: 12, left: 12, bottom: 12, right: 12))

    addSubview(mainStack)
    mainStack.fillSuperview()

    // Ensure AdTag and AdChoices are on top
    bringSubviewToFront(adTag)
    bringSubviewToFront(adChoicesContainer)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

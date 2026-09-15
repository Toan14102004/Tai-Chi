//
//  NativeAdMediumMediaView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/9/25.
//

import Foundation
import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdMediumMediaView: NativeAdView {
  let adTag: UILabel = .init(
    text: "Ad", font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor)
  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 17, weight: .medium), textColor: Asset.Color.white.uiColor)
  let myMediaView = MediaView()
  let callToActionButton = UIButton(
    title: "Install",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 16),
    backgroundColor: Asset.Color.primary.uiColor,
    target: nil,
    action: nil
  )
  let iconImageView = UIImageView()
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)
  let starRatingImageView = UIImageView()
  let advertiserLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  func setupViews() {
    headlineView = headlineLabel
    advertiserView = advertiserLabel

    // Configure media view
    myMediaView.translatesAutoresizingMaskIntoConstraints = false
    myMediaView.backgroundColor = .clear
    myMediaView.layer.cornerRadius = 8
    myMediaView.clipsToBounds = true
    mediaView = myMediaView

    // Configure icon view
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.layer.cornerRadius = 20  // Make it circular
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFill
    iconView = iconImageView

    callToActionButton.layer.cornerRadius = 8
    callToActionButton.clipsToBounds = true
    callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    callToActionView = callToActionButton

    bodyLabel.numberOfLines = 2
    bodyLabel.textColor = Asset.Color.white.uiColor
    bodyView = bodyLabel

    starRatingImageView.withWidth(100).withHeight(17)
    starRatingView = starRatingImageView

    adTag.withWidth(25)
    adTag.textAlignment = .center
    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 2
    adTag.clipsToBounds = true
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")

    // Position ad tag in top-left corner
    addSubview(adTag)
    adTag.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      adTag.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      adTag.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
    ])

    backgroundColor = Asset.Color.black.uiColor

    // Setup layout
    setupLayout()
  }

  private func setupLayout() {
    let mediaContainer = UIView()
    mediaContainer.addSubview(myMediaView)
    myMediaView.fillSuperview()

    mediaContainer.widthAnchor.constraint(equalTo: mediaContainer.heightAnchor, multiplier: 4 / 3)
      .isActive = true

    // Text Content
    headlineLabel.numberOfLines = 1
    bodyLabel.numberOfLines = 1

    // Stack labels closely
    let textStack = stack(headlineLabel, bodyLabel, spacing: 2)
    textStack.alignment = .leading

    // Wrap textStack to center it vertically
    let textWrapper = UIView()
    textWrapper.addSubview(textStack)
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.centerYAnchor.constraint(equalTo: textWrapper.centerYAnchor).isActive = true
    textStack.leadingAnchor.constraint(equalTo: textWrapper.leadingAnchor).isActive = true
    textStack.trailingAnchor.constraint(equalTo: textWrapper.trailingAnchor).isActive = true

    // Main Layout
    // Use spacing 8 for tighter layout
    let mainStack = hstack(mediaContainer, textWrapper, spacing: 8)
    addSubview(mainStack)
    mainStack.fillSuperview(padding: .init(top: 8, left: 8, bottom: 8, right: 8))

    // Styling
    mediaContainer.layer.cornerRadius = 8
    mediaContainer.clipsToBounds = true

    bringSubviewToFront(adTag)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

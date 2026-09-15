//
//  NativeAdBannerView.swift
//
//
//  Created by minghui on 2023/6/15.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdBannerView: NativeAdView {
  let adTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )
  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 15, weight: .medium), textColor: Asset.Color.textPrimary.uiColor)
  let iconImageView = UIImageView()
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.textSecondary.uiColor)
  let starRatingImageView = UIImageView()
  let callToActionButton = UIButton(
    title: "Install",
    titleColor: Asset.Color.white.uiColor,
    font: .boldSystemFont(ofSize: 14),
    backgroundColor: .clear,
    target: nil,
    action: nil
  )
  private let callToActionGradientLayer = AppGradient.makeCAGradientLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  func setupViews() {
    headlineView = headlineLabel
    iconView = iconImageView
    bodyView = bodyLabel

    // Configure ad tag
    adTag.withWidth(25)
    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 4
    adTag.clipsToBounds = true
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")
    adTag.textColor = Asset.Color.black.uiColor

    // Set background for the entire view
    backgroundColor = Asset.Color.bgAds.uiColor

    // Configure icon
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFit

    // Configure headline
    headlineLabel.numberOfLines = 2
    headlineLabel.lineBreakMode = .byWordWrapping

    // Configure body text
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byWordWrapping

    // Configure install button
    callToActionButton.layer.cornerRadius = 8
    callToActionButton.clipsToBounds = true
    callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    callToActionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    callToActionButton.setContentHuggingPriority(.required, for: .horizontal)
    callToActionGradientLayer.cornerRadius = 8
    callToActionButton.layer.insertSublayer(callToActionGradientLayer, at: 0)
    callToActionView = callToActionButton

    // Position ad tag in top-left corner
    addSubview(adTag)
    adTag.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      adTag.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      adTag.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
    ])

    // Main content layout
    let textStack = stack(headlineLabel, bodyLabel, spacing: 4)
    let contentStack = hstack(iconImageView, textStack, spacing: 12)
    let mainStack = hstack(contentStack, callToActionButton, spacing: 12)

    addSubview(mainStack)
    mainStack.withMargins(.init(top: 16, left: 8, bottom: 8, right: 8))
    mainStack.fillSuperview()
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

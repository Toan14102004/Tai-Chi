//
//  NativeAdFullScreenView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/9/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdFullScreenView: NativeAdView {
  let iconImageView = UIImageView()
  let adTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 12, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )
  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 18, weight: .bold), textColor: Asset.Color.white.uiColor)
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)
  let myMediaView = MediaView()
  let callToActionButton = UIButton(
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
    headlineView = headlineLabel
    bodyView = bodyLabel

    // Configure icon view (logo)
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFill
    // Set background color so icon is visible even when image hasn't loaded yet
    iconImageView.backgroundColor = .systemGray5
    iconView = iconImageView

    // Configure media view
    myMediaView.translatesAutoresizingMaskIntoConstraints = false
    myMediaView.backgroundColor = .clear
    myMediaView.contentMode = .scaleAspectFit
    myMediaView.clipsToBounds = true
    mediaView = myMediaView

    // Configure call to action button
    callToActionButton.translatesAutoresizingMaskIntoConstraints = false
    callToActionButton.layer.cornerRadius = 22
    callToActionButton.clipsToBounds = true
    callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    callToActionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    callToActionView = callToActionButton

    // Configure ad tag
    adTag.translatesAutoresizingMaskIntoConstraints = false
    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 4
    adTag.clipsToBounds = true
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")
    adTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
    adTag.heightAnchor.constraint(equalToConstant: 20).isActive = true

    // Configure headline
    headlineLabel.numberOfLines = 2
    headlineLabel.lineBreakMode = .byWordWrapping

    // Configure body text
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byWordWrapping
    bodyLabel.textColor = Asset.Color.white.uiColor

    // Setup layout
    setupLayout()
  }

  private func setupLayout() {
    layer.cornerRadius = 12
    clipsToBounds = true
    backgroundColor = Asset.Color.black.uiColor

    let textStack = stack(
      headlineLabel,
      hstack(adTag, UIView(), spacing: 8),
      spacing: 4
    )

    var bottomContent: UIStackView
    if let icon = iconView as? UIImageView, icon.image != nil {
      bottomContent = hstack(iconImageView, textStack, spacing: 12)
    } else {
      bottomContent = hstack(textStack, spacing: 12)
    }

    let bottomStack = stack(bottomContent, callToActionButton, spacing: 16)

    let mainStack = stack(myMediaView, bottomStack, spacing: 0)

    addSubview(mainStack)
    mainStack.withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
    mainStack.fillSuperview()

    myMediaView.setContentHuggingPriority(.defaultLow, for: .vertical)
    myMediaView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    bottomStack.setContentHuggingPriority(.required, for: .vertical)
    bottomStack.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

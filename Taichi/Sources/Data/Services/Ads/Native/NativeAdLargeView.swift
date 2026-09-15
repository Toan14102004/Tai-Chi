//
//  NativeAdLargeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/9/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdLargeView: NativeAdView {
  // require
  let myMediaView = MediaView()
  let iconImageView = UIImageView()
  let headlineLabel = UILabel(
    text: "",
    font: FontFamily.Inter.medium.font(size: 15),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 2
  )
  let adTag: PaddingLabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.blue.uiColor,
    textAlignment: .center
  )

  // for web
  let bodyLabel = UILabel(
    text: "",
    font: .systemFont(ofSize: 14, weight: .regular),
    textColor: Asset.Color.white.uiColor,
    numberOfLines: 3
  )

  let installButton = UIButton(
    title: "INSTALL",
    titleColor: Asset.Color.white.uiColor,
    font: .boldSystemFont(ofSize: 16),
    backgroundColor: .clear,
    target: nil,
    action: nil
  )

  // Container for button alignment
  private let buttonContainer = UIView()

  // Store the aspect ratio constraint to update it dynamically
  private var mediaAspectConstraint: NSLayoutConstraint?

  // Store button width constraint
  private var buttonWidthConstraint: NSLayoutConstraint?

  // Store button style state
  private var isButtonFilled: Bool = true

  // Gradient background for the filled install button (AppGradient.mainGradient)
  private let installButtonGradientLayer = AppGradient.makeCAGradientLayer()

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

    let mediaAspect = myMediaView.heightAnchor.constraint(
      equalTo: myMediaView.widthAnchor, multiplier: 9.0 / 16.0)
    mediaAspect.priority = .defaultHigh
    mediaAspect.isActive = true
    myMediaView.heightAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
    mediaView = myMediaView

    headlineView = headlineLabel
    headlineLabel.numberOfLines = 2
    headlineLabel.lineBreakMode = .byTruncatingTail
    headlineLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    headlineLabel.setContentHuggingPriority(.required, for: .vertical)

    // Configure install button (acts as the single CTA below media)
    installButton.translatesAutoresizingMaskIntoConstraints = false
    installButton.layer.cornerRadius = 8
    installButton.clipsToBounds = true
    installButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    installButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    installButton.layer.insertSublayer(installButtonGradientLayer, at: 0)
    callToActionView = installButton

    // Setup button container
    buttonContainer.translatesAutoresizingMaskIntoConstraints = false
    buttonContainer.addSubview(installButton)

    // Initially set button to fill container width
    NSLayoutConstraint.activate([
      installButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
      installButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
      installButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
      installButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
    ])

    updateButtonStyle()

    let leftStack = stack(headlineLabel, spacing: 2)
      .withMargins(
        .init(
          top: 0,
          left: 0,
          bottom: 0,
          right: 8
        ))

    var topContent: UIStackView
    if let icon = iconView as? UIImageView, icon.image != nil {
      topContent = hstack(iconImageView, leftStack, spacing: 8)
    } else {
      topContent = hstack(leftStack, spacing: 8)
    }

    // Media placed above install button container
    let mediaAndButton = stack(myMediaView, buttonContainer, spacing: 8)
    // Main layout with media + install button at bottom
    let mainStack = stack(topContent, mediaAndButton, spacing: 8).withMargins(
      .init(
        top: 20,
        left: 8,
        bottom: 8,
        right: 8
      ))
    addSubview(mainStack)
    mainStack.fillSuperview()

    // AD Tag Label
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

    adTag.backgroundColor = Asset.Color.blue.uiColor.withAlphaComponent(0.1)
    adTag.layer.cornerRadius = Layout.CornerRadius.medium
    adTag.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
    adTag.clipsToBounds = true
    adTag.textColor = Asset.Color.blue.uiColor

    // Set black background for the entire view
      backgroundColor = Asset.Color.bgAds.uiColor
  }

  // Method to update media aspect ratio dynamically
  func updateMediaAspectRatio(_ aspectRatio: CGFloat) {
    mediaAspectConstraint?.isActive = false

    let multiplier: CGFloat
    if aspectRatio > 0 {
      // Convert aspect ratio to height/width multiplier
      multiplier = 1.0 / aspectRatio
    } else {
      // Default to 16:9
      multiplier = 9.0 / 16.0
    }

    mediaAspectConstraint = myMediaView.heightAnchor.constraint(
      equalTo: myMediaView.widthAnchor,
      multiplier: multiplier
    )
    mediaAspectConstraint?.priority = .defaultHigh
    mediaAspectConstraint?.isActive = true

    layoutIfNeeded()
  }

  // Method to set button style (filled or outline)
  func setButtonStyle(filled: Bool) {
    isButtonFilled = filled
    updateButtonStyle()
    updateButtonWidth()
  }

  // Method to update button appearance based on style
  private func updateButtonStyle() {
    if isButtonFilled {
      // Filled style — shared app gradient (AppGradient.mainGradient)
      installButton.backgroundColor = .clear
      installButtonGradientLayer.isHidden = false
      installButton.setTitleColor(Asset.Color.white.uiColor, for: .normal)
      installButton.layer.borderWidth = 0
    } else {
      // Outline style
      installButtonGradientLayer.isHidden = true
      installButton.backgroundColor = Asset.Color.gray.uiColor.withAlphaComponent(0.6)
      installButton.setTitleColor(Asset.Color.black.uiColor.withAlphaComponent(0.6), for: .normal)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    installButtonGradientLayer.frame = installButton.bounds
  }

  // Method to update button width based on style
  private func updateButtonWidth() {
    // Remove all existing horizontal constraints for button
    installButton.constraints.forEach { constraint in
      if constraint.firstAttribute == .width {
        constraint.isActive = false
      }
    }

    // Remove button's leading/trailing constraints from superview
    buttonContainer.constraints.forEach { constraint in
      if (constraint.firstItem as? UIButton) == installButton
        || (constraint.secondItem as? UIButton) == installButton
      {
        if constraint.firstAttribute == .leading || constraint.firstAttribute == .trailing {
          constraint.isActive = false
        }
      }
    }

    if isButtonFilled {
      // Full width - button fills container
      NSLayoutConstraint.activate([
        installButton.leadingAnchor.constraint(
          equalTo: buttonContainer.leadingAnchor, constant: 16),
        installButton.trailingAnchor.constraint(
          equalTo: buttonContainer.trailingAnchor, constant: -16),
      ])
    } else {
      // 2/5 width and align to trailing (right)
      buttonWidthConstraint = installButton.widthAnchor.constraint(
        equalTo: buttonContainer.widthAnchor,
        multiplier: 2.0 / 5.0
      )

      NSLayoutConstraint.activate([
        buttonWidthConstraint!,
        installButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
      ])
    }

    layoutIfNeeded()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

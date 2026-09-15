//
//  NativeAdOverlayView.swift
//  Taichi
//
//  Created by Toan Nguyen on 23/12/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdOverlayView: NativeAdView {
  let adTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )
  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 16, weight: .bold), textColor: .white)
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 13, weight: .regular), textColor: .white)
  let callToActionButton = UIButton(
    title: "Open",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 14),
    backgroundColor: Asset.Color.primary.uiColor,
    target: nil,
    action: nil
  )
  let myMediaView = MediaView()
  let gradientLayer = CAGradientLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }

  func setupViews() {
    headlineView = headlineLabel
    bodyView = bodyLabel
    mediaView = myMediaView
    callToActionView = callToActionButton

    // Configure ad tag
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")

    let adTagWrapper = UIView()
    adTagWrapper.backgroundColor = Asset.Color.primary.uiColor
    adTagWrapper.layer.cornerRadius = 4
    adTagWrapper.clipsToBounds = true
    adTagWrapper.stack(adTag).withMargins(.init(top: 2, left: 6, bottom: 2, right: 6))
    adTagWrapper.setContentHuggingPriority(.required, for: .horizontal)
    adTagWrapper.setContentCompressionResistancePriority(.required, for: .horizontal)

    // Configure headline
    headlineLabel.numberOfLines = 1
    headlineLabel.lineBreakMode = .byTruncatingTail

    // Configure body
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byTruncatingTail
    bodyLabel.alpha = 0.9  // Slight transparency for visual hierarchy

    // Configure Media View (Background)
    myMediaView.translatesAutoresizingMaskIntoConstraints = false
    myMediaView.backgroundColor = .secondarySystemBackground
    myMediaView.contentMode = .scaleAspectFill
    myMediaView.clipsToBounds = true

    // Configure Call To Action Button
    callToActionButton.layer.cornerRadius = 21
    callToActionButton.clipsToBounds = true
    callToActionButton.withWidth(100)

    // --- Layout ---

    // 1. Add MediaView as Background
    addSubview(myMediaView)
    myMediaView.fillSuperview()

    // 2. Add Gradient for Text Visibility
    gradientLayer.colors = [
      UIColor.clear.cgColor,
      UIColor.black.withAlphaComponent(0.6).cgColor,
    ]
    gradientLayer.locations = [0.5, 1.0]
    layer.addSublayer(gradientLayer)

    // 3. Info Overlay (Bottom)

    // Left Text Stack
    let bodyStack = hstack(adTagWrapper, bodyLabel, spacing: 4, alignment: .top)
    let textStack = stack(headlineLabel, bodyStack, spacing: 4, alignment: .leading).withMargins(
      .init(top: 0, left: 12, bottom: 0, right: 0))

    // Main Bottom Stack (Text + Button)
    let bottomStack = hstack(
      textStack,
      UIView(),  // Spacer
      callToActionButton.withHeight(42),
      spacing: 12,
      alignment: .bottom
    )

    addSubview(bottomStack)
    bottomStack.anchor(
      top: nil,
      leading: leadingAnchor,
      bottom: bottomAnchor,
      trailing: trailingAnchor,
      padding: .init(top: 0, left: 16, bottom: 16, right: 16)
    )

    // Apply Corner Radius to the whole View
    layer.cornerRadius = 12
    clipsToBounds = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

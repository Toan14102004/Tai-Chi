//
//  NativeAdSmallMediaView.swift
//  Taichi
//
//  Created by Toan Nguyen on 23/12/25.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdSmallMediaView: NativeAdView {
  let adTag: PaddingLabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )
  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 16, weight: .bold), textColor: Asset.Color.white.uiColor)
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 13, weight: .regular), textColor: Asset.Color.white.uiColor)
  let callToActionButton = UIButton(
    title: "Open",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 14),
    backgroundColor: Asset.Color.primary.uiColor,
    target: nil,
    action: nil
  )
  let myMediaView = MediaView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  func setupViews() {
    headlineView = headlineLabel
    bodyView = bodyLabel
    mediaView = myMediaView
    callToActionView = callToActionButton

    // Configure ad tag
    adTag.topInset = 2
    adTag.bottomInset = 2
    adTag.leftInset = 4
    adTag.rightInset = 4
    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 2
    adTag.clipsToBounds = true
    adTag.text = NSLocalizedString("Ad", comment: "Ad tag label")

    // Configure headline
    headlineLabel.numberOfLines = 1
    headlineLabel.lineBreakMode = .byTruncatingTail

    // Configure body
    bodyLabel.numberOfLines = 2
    bodyLabel.lineBreakMode = .byTruncatingTail

    // Configure Media View (Left Side)
    myMediaView.translatesAutoresizingMaskIntoConstraints = false
    myMediaView.layer.cornerRadius = 12
    myMediaView.clipsToBounds = true
    myMediaView.contentMode = .scaleAspectFill

    // Configure Call To Action Button
    callToActionButton.layer.cornerRadius = 21
    callToActionButton.clipsToBounds = true

    // --- Layout ---

    // Right Side Column

    // 1. Title
    // 2. Ad Tag + Body
    let bodyStack = hstack(adTag, bodyLabel, UIView(), spacing: 4, alignment: .top)

    // 3. Button

    let rightStack = stack(
      headlineLabel,
      bodyStack,
      UIView(),  // Spacer
      callToActionButton.withHeight(42),
      spacing: 4
    )

    // Main Horizontal Layout
    let mainStack = hstack(
      myMediaView,  // Width constraint set below
      rightStack,
      spacing: 12
    )
    .withMargins(.init(top: 20, left: 12, bottom: 20, right: 12))

    addSubview(mainStack)

    // Constraint: Media view takes 50% of total width
    myMediaView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true

    // Configure AdOptions/AdChoices View
    let adChoicesContainer = AdChoicesView()
    adChoicesContainer.backgroundColor = .clear
    addSubview(adChoicesContainer)
    adChoicesContainer.anchor(
      top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,
      size: .init(width: 20, height: 20))
    adChoicesContainer.clipsToBounds = true
    self.adChoicesView = adChoicesContainer
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

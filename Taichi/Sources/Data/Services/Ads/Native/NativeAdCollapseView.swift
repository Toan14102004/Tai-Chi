//
//  NativeAdCollapseView.swift
//
//
//  Created by AI Assistant on 2025/12/24.
//

import GoogleMobileAds
import LBTATools
import UIKit

class NativeAdCollapseView: NativeAdView {  // Đảm bảo kế thừa từ NativeAdView

  // MARK: - UI Components
  let adTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )

  let mediaContentView = MediaView()

  let closeButton: UIButton = {
    let btn = UIButton(type: .system)
    let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
    btn.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
    btn.tintColor = Asset.Color.white.uiColor
    return btn
  }()

  let headlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 15, weight: .medium), textColor: Asset.Color.white.uiColor)
  let iconImageView = UIImageView()
  let bodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)
  let callToActionButton = UIButton(
    title: "Install",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 14),
    backgroundColor: Asset.Color.primary.uiColor,  // #3871E0
    target: nil,
    action: nil
  )

  // MARK: - Collapsed UI Components (Image 2 Style)
  let collapsedAdTag: UILabel = .init(
    text: "Ad",
    font: .systemFont(ofSize: 10, weight: .semibold),
    textColor: Asset.Color.black.uiColor,
    textAlignment: .center
  )
  let collapsedHeadlineLabel = UILabel(
    text: "", font: .systemFont(ofSize: 15, weight: .bold), textColor: Asset.Color.white.uiColor)
  let collapsedBodyLabel = UILabel(
    text: "", font: .systemFont(ofSize: 14, weight: .regular), textColor: Asset.Color.white.uiColor)
  let collapsedCallToActionButton = UIButton(
    title: "Open",
    titleColor: Asset.Color.black.uiColor,
    font: .boldSystemFont(ofSize: 16),
    backgroundColor: Asset.Color.primary.uiColor,  // #3871E0
    target: nil,  // Add target later or rely on user interaction disabled for container click
    action: nil
  )

  var expandedBottomStack: UIStackView!
  var collapsedBottomStack: UIStackView!

  // Stack chứa MediaView để dễ dàng ẩn hiện
  // Stack chứa MediaView để dễ dàng ẩn hiện
  var mediaContainerStack: UIView!
  var onCollapse: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  override var nativeAd: NativeAd? {
    didSet {
      guard nativeAd !== oldValue else { return }
      // If there is no media content (or aspect ratio is 0), hide the media container
      if let mediaContent = nativeAd?.mediaContent,
        mediaContent.aspectRatio > 0,
        mediaContent.hasVideoContent || mediaContent.mainImage != nil
      {
        // Reset UI to expanded state
        mediaContainerStack.isHidden = false
        mediaContainerStack.alpha = 1
        mediaContentView.isHidden = false
        mediaContentView.alpha = 1
        mediaView = mediaContentView  // Re-assign mediaView

        // Show expanded bottom stack, hide collapsed
        expandedBottomStack.isHidden = false
        collapsedBottomStack.isHidden = true
        adTag.isHidden = true  // Hide floating tag in Expanded (Vertical) mode

        // Re-bind assets to expanded views (Vertical UI)
        headlineView = collapsedHeadlineLabel
        callToActionView = collapsedCallToActionButton
        bodyView = collapsedBodyLabel

        // iconView is not in Vertical UI
        iconView = nil

      } else {
        mediaContainerStack.isHidden = true
        mediaView = nil  // Unassign mediaView so validator doesn't check it

        // If media is missing initially, we might want to start in collapsed mode?
        // For now, respect the original logic which just hides media container.
        // But the user request specifically asks about collapse ACTION.
        DispatchQueue.main.async {
          self.onCollapse?()
        }
      }

      // Populate collapsed views with same data
      collapsedHeadlineLabel.text = nativeAd?.headline
      collapsedBodyLabel.text = nativeAd?.body
      collapsedCallToActionButton.setTitle(nativeAd?.callToAction, for: .normal)

      // Register views with the ad object AFTER configuring the view hierarchy
      super.nativeAd = nativeAd
    }
  }

  func setupViews() {
    // Gán view cho Google SDK quản lý
    headlineView = headlineLabel
    iconView = iconImageView
    bodyView = bodyLabel
    callToActionView = callToActionButton
    mediaView = mediaContentView

    // 1. Config Media Section
    mediaContentView.contentMode = .scaleAspectFill
    mediaContentView.clipsToBounds = true

    // Container cho media và nút close
    mediaContainerStack = UIView()
    mediaContainerStack.addSubview(mediaContentView)
    mediaContainerStack.addSubview(closeButton)
    mediaContainerStack.isHidden = true

    mediaContentView.fillSuperview()
    closeButton.anchor(
      top: mediaContainerStack.topAnchor, leading: nil, bottom: nil,
      trailing: mediaContainerStack.trailingAnchor,
      padding: .init(top: 8, left: 0, bottom: 0, right: 16))
    closeButton.withSize(.init(width: 30, height: 30))
    closeButton.layer.cornerRadius = 15
    closeButton.backgroundColor = .white
    closeButton.tintColor = Asset.Color.white.uiColor

    // Thiết lập tỉ lệ cho MediaView (thường là 16:9 hoặc cố định chiều cao)
    mediaContainerStack.heightAnchor.constraint(
      equalTo: mediaContainerStack.widthAnchor, multiplier: 0.6
    ).isActive = true

    // 2. Config Banner Section (Phần dưới)
    adTag.withWidth(25).withHeight(16)
    adTag.backgroundColor = Asset.Color.primary.uiColor
    adTag.layer.cornerRadius = 4
    adTag.clipsToBounds = true

    iconImageView.withSize(.init(width: 40, height: 40))
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFit

    headlineLabel.numberOfLines = 1
    bodyLabel.numberOfLines = 2

    // 3. Layout Main Stack
    // 3. Layout Main Stack
    // 3. Layout Main Stack
    // 3. Layout Main Stack
    // Expanded Stack (Now Vertical UI: AdTag + Headline + Open Button)
    // Note: Using 'collapsed' components for the expanded stack as per swap request
    collapsedAdTag.withWidth(25).withHeight(16)
    collapsedAdTag.backgroundColor = Asset.Color.primary.uiColor
    collapsedAdTag.layer.cornerRadius = 4
    collapsedAdTag.clipsToBounds = true

    collapsedCallToActionButton.layer.cornerRadius = 24  // Pill shape for 48 height
    collapsedCallToActionButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

    collapsedHeadlineLabel.numberOfLines = 1
    collapsedHeadlineLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    collapsedAdTag.heightAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true

    collapsedBodyLabel.numberOfLines = 2

    let titleStack = hstack(collapsedAdTag, collapsedHeadlineLabel, spacing: 6, alignment: .center)
    expandedBottomStack = stack(titleStack, collapsedCallToActionButton, spacing: 4)
    expandedBottomStack.setCustomSpacing(2, after: titleStack)
    expandedBottomStack.isLayoutMarginsRelativeArrangement = true
    expandedBottomStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    // Collapsed Stack (Now Banner UI: Icon + Headline + Body + Install Button)
    // Note: Using 'standard' components for the collapsed stack as per swap request
    iconImageView.withSize(.init(width: 40, height: 40))
    iconImageView.layer.cornerRadius = 8
    iconImageView.clipsToBounds = true
    iconImageView.contentMode = .scaleAspectFit

    headlineLabel.numberOfLines = 1
    bodyLabel.numberOfLines = 2

    callToActionButton.layer.cornerRadius = 24
    callToActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    callToActionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    callToActionButton.setContentHuggingPriority(.required, for: .horizontal)
    callToActionButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

    let textStack = stack(headlineLabel, bodyLabel, spacing: 2)
    collapsedBottomStack = hstack(
      iconImageView, textStack, callToActionButton, spacing: 12, alignment: .center)
    collapsedBottomStack.isLayoutMarginsRelativeArrangement = true
    collapsedBottomStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    collapsedBottomStack.isHidden = true  // Initially hidden

    // Stack tổng chứa tất cả
    let rootStack = stack(mediaContainerStack, expandedBottomStack, collapsedBottomStack)
    addSubview(rootStack)
    rootStack.fillSuperview()

    // 4. Ad Tag Position (Floating trên cùng bên trái - chỉ cho Expanded Mode khi dùng Banner UI cũ, giờ Expanded là Vertical UI đã có tag rồi nên ẩn cái này đi hoặc chỉ hiện khi cần)
    // Trong Vertical UI (expandedBottomStack mới), ta đã có collapsedAdTag bên trong stack.
    // Nút 'Ad' cũ (adTag) là floating. Nếu muốn giữ nó cho Collapsed State (Banner UI) thì custom lại.
    // Tuy nhiên theo logic cũ: Expanded (Banner) có AdTag floating.
    // Giờ Expanded (Vertical) đã có AdTag inline. => Ẩn Floating AdTag khi Expanded.
    // Collapsed (Banner) => Cần hiện AdTag floating?
    // Để đơn giản và match UI:
    // Expanded (Vertical) -> Hide floating tag.
    // Collapsed (Banner) -> Show floating tag.

    addSubview(adTag)
    adTag.anchor(
      top: topAnchor,
      leading: leadingAnchor,
      bottom: nil,
      trailing: nil,
      padding: .init(top: 0, left: 0, bottom: 0, right: 0)
    )
    adTag.isHidden = true  // Hidden initially for Expanded (Vertical) state

    // 5. Visual Styling for Taichi Appearance (Fix for Layout Issue)
    self.backgroundColor = Asset.Color.black.uiColor
    self.layer.cornerRadius = 16
    self.clipsToBounds = true

    mediaContainerStack.backgroundColor = Asset.Color.gray.uiColor.withAlphaComponent(0.8)

    // 6. Action cho nút Close
    closeButton.addTarget(self, action: #selector(handleCollapse), for: .touchUpInside)
  }

  private func updateAdRegistration() {
    super.nativeAd = nativeAd
  }

  @objc func handleCollapse() {
    if !mediaContentView.isHidden {
      // Lần nhấn đầu tiên: chỉ ẩn mediaView
      UIView.animate(withDuration: 0.3) {
        self.mediaContentView.isHidden = true
        self.mediaContentView.alpha = 0
      }
    } else {
      // Lần nhấn thứ 2: ẩn toàn bộ mediaContainerStack
      UIView.animate(
        withDuration: 0.3,
        animations: { [weak self] in
          guard let self = self else { return }
          self.mediaContentView.isHidden = true
          self.mediaContentView.alpha = 0
          self.mediaContainerStack.isHidden = true
          self.mediaContainerStack.alpha = 0

          // Switch to Collapsed Bottom Stack
          self.expandedBottomStack.isHidden = true
          self.collapsedBottomStack.isHidden = false
          self.collapsedBottomStack.alpha = 0
          self.adTag.isHidden = false  // Show floating tag for Collapsed (Banner) mode

          UIView.animate(withDuration: 0.2) {
            self.collapsedBottomStack.alpha = 1
          }

          // Re-bind assets to collapsed views (Banner UI) for click tracking
          self.headlineView = self.headlineLabel
          self.bodyView = self.bodyLabel
          self.callToActionView = self.callToActionButton
          self.iconView = self.iconImageView

          // Re-register ad to update click areas
          self.updateAdRegistration()

          self.layoutIfNeeded()
          self.onCollapse?()
        })
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

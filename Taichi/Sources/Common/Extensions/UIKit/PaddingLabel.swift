//
//  PaddingLabel.swift
//  Taichi
//
//  Created by AI Assistant on 2025/12/24.
//

import UIKit

class PaddingLabel: UILabel {
    var topInset: CGFloat = 2.0
    var bottomInset: CGFloat = 2.0
    var leftInset: CGFloat = 4.0
    var rightInset: CGFloat = 4.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if needed
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}

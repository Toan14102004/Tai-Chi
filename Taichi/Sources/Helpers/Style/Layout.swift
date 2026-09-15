//
//  Layout.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/18/25.
//
//  Updated to comply with Apple Human Interface Guidelines
//  Reference: https://developer.apple.com/design/human-interface-guidelines

import Foundation
import SwiftUI

// MARK: - Adaptive Size
/// A value that adapts between iPhone and iPad.
/// Ideally, access these via `Layout` static properties which return the resolved `CGFloat` directly.
public struct AdaptiveSize {
    public let iPhoneSize: CGFloat
    public let iPadSize: CGFloat
    
    public init(iPhoneSize: CGFloat, iPadSize: CGFloat) {
        self.iPhoneSize = iPhoneSize
        self.iPadSize = iPadSize
    }
    
    /// Resolved size for the current device.
    public var value: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? iPadSize : iPhoneSize
    }
}

// MARK: - Layout Namespace
public enum Layout {

    // MARK: - Hero

    /// Height of the photo/video header on the Schedule, Workout Day and Exercise Detail screens,
    /// measured below the status bar -- callers add the safe-area inset so the media itself runs
    /// edge to edge behind it.
    public static let heroHeight: CGFloat = 220

    /// Horizontal inset for the primary footer button on the Workout Day and Discover workout
    /// screens. The design centres a 296pt button on a 375pt screen rather than running it to the
    /// 16pt content margin.
    public static let footerInset: CGFloat = 40

    // MARK: - Spacing
    /// Spacing values following Apple's 8pt grid system.
    /// Use these for padding, margins, and gaps between elements.
    public enum Spacing {
        private static let xxsAdaptive = AdaptiveSize(iPhoneSize: 2, iPadSize: 4)
        private static let xsAdaptive = AdaptiveSize(iPhoneSize: 4, iPadSize: 8)
        private static let sAdaptive = AdaptiveSize(iPhoneSize: 8, iPadSize: 16)
        private static let mAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 24)
        private static let lAdaptive = AdaptiveSize(iPhoneSize: 24, iPadSize: 32)
        private static let xlAdaptive = AdaptiveSize(iPhoneSize: 32, iPadSize: 48)
        private static let xxlAdaptive = AdaptiveSize(iPhoneSize: 48, iPadSize: 64)
        private static let xxxlAdaptive = AdaptiveSize(iPhoneSize: 64, iPadSize: 80)
        
        /// 2pt / 4pt - Minimal spacing
        public static var xxs: CGFloat { xxsAdaptive.value }
        /// 4pt / 8pt - Extra small spacing
        public static var xs: CGFloat { xsAdaptive.value }
        /// 8pt / 16pt - Small spacing (base unit)
        public static var s: CGFloat { sAdaptive.value }
        /// 16pt / 24pt - Medium spacing (Apple HIG recommended margin)
        public static var m: CGFloat { mAdaptive.value }
        /// 24pt / 32pt - Large spacing
        public static var l: CGFloat { lAdaptive.value }
        /// 32pt / 48pt - Extra large spacing
        public static var xl: CGFloat { xlAdaptive.value }
        /// 48pt / 64pt - 2x large spacing
        public static var xxl: CGFloat { xxlAdaptive.value }
        /// 64pt / 80pt - 3x large spacing
        public static var xxxl: CGFloat { xxxlAdaptive.value }
    }
    
    // MARK: - Margin
    /// Content margins following Apple HIG recommendations.
    /// iPhone: 16pt horizontal margins, iPad: 24pt horizontal margins.
    public enum Margin {
        private static let horizontalAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 24)
        private static let contentAdaptive = AdaptiveSize(iPhoneSize: 20, iPadSize: 28)
        private static let safeAreaAdaptive = AdaptiveSize(iPhoneSize: 8, iPadSize: 12)
        private static let sectionAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 20)
        
        /// 16pt / 24pt - Standard horizontal margin (Apple HIG)
        public static var horizontal: CGFloat { horizontalAdaptive.value }
        /// 20pt / 28pt - Content inset margin
        public static var content: CGFloat { contentAdaptive.value }
        /// 8pt / 12pt - Minimum safe area padding
        public static var safeArea: CGFloat { safeAreaAdaptive.value }
        /// 16pt / 20pt - Section separator margin
        public static var section: CGFloat { sectionAdaptive.value }
    }
    
    // MARK: - Touch Target
    /// Touch target sizes following Apple HIG accessibility requirements.
    /// Minimum touch target: 44x44pt for accessibility compliance.
    public enum TouchTarget {
        private static let minimumAdaptive = AdaptiveSize(iPhoneSize: 44, iPadSize: 44)
        private static let comfortableAdaptive = AdaptiveSize(iPhoneSize: 48, iPadSize: 56)
        private static let largeAdaptive = AdaptiveSize(iPhoneSize: 56, iPadSize: 64)
        
        /// 44pt - Apple HIG minimum touch target (accessibility requirement)
        public static var minimum: CGFloat { minimumAdaptive.value }
        /// 48pt / 56pt - Comfortable touch target
        public static var comfortable: CGFloat { comfortableAdaptive.value }
        /// 56pt / 64pt - Large touch target for prominent actions
        public static var large: CGFloat { largeAdaptive.value }
    }
    
    // MARK: - Corner Radius
    /// Corner radius values for rounded elements.
    public enum CornerRadius {
        private static let xsAdaptive = AdaptiveSize(iPhoneSize: 2, iPadSize: 4)
        private static let smallAdaptive = AdaptiveSize(iPhoneSize: 4, iPadSize: 6)
        private static let mediumAdaptive = AdaptiveSize(iPhoneSize: 8, iPadSize: 12)
        private static let largeAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 20)
        private static let xlAdaptive = AdaptiveSize(iPhoneSize: 20, iPadSize: 28)
        private static let xxlAdaptive = AdaptiveSize(iPhoneSize: 24, iPadSize: 32)
        private static let xxxlAdaptive = AdaptiveSize(iPhoneSize: 40, iPadSize: 56)
        
        /// 2pt / 4pt - Extra small radius
        public static var xs: CGFloat { xsAdaptive.value }
        /// 4pt / 6pt - Small radius
        public static var small: CGFloat { smallAdaptive.value }
        /// 8pt / 12pt - Medium radius (buttons, foods)
        public static var medium: CGFloat { mediumAdaptive.value }
        /// 12pt / 16pt - Large radius (modals, sheets)
        public static var large: CGFloat { largeAdaptive.value }
        /// 16pt / 20pt - Extra large radius
        public static var xl: CGFloat { xlAdaptive.value }
        /// 24pt / 32pt - 2x large radius
        public static var xxl: CGFloat { xxlAdaptive.value }
        /// 40pt / 56pt - 3x large radius (pills, capsules)
        public static var xxxl: CGFloat { xxxlAdaptive.value }
    }
    
    // MARK: - Icon Size
    /// Icon sizes for SF Symbols and custom icons.
    public enum Icon {
        private static let xxsAdaptive = AdaptiveSize(iPhoneSize: 10, iPadSize: 12)
        private static let xsAdaptive = AdaptiveSize(iPhoneSize: 12, iPadSize: 16)
        private static let smallAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 20)
        private static let mediumAdaptive = AdaptiveSize(iPhoneSize: 24, iPadSize: 32)
        private static let largeAdaptive = AdaptiveSize(iPhoneSize: 32, iPadSize: 44)
        private static let xlAdaptive = AdaptiveSize(iPhoneSize: 40, iPadSize: 56)
        private static let xxlAdaptive = AdaptiveSize(iPhoneSize: 56, iPadSize: 72)
        
        /// 10pt / 12pt - Extra extra small icon
        public static var xxs: CGFloat { xxsAdaptive.value }
        /// 12pt / 16pt - Extra small icon
        public static var xs: CGFloat { xsAdaptive.value }
        /// 16pt / 20pt - Small icon (inline with text)
        public static var small: CGFloat { smallAdaptive.value }
        /// 24pt / 32pt - Medium icon (default)
        public static var medium: CGFloat { mediumAdaptive.value }
        /// 32pt / 44pt - Large icon
        public static var large: CGFloat { largeAdaptive.value }
        /// 40pt / 56pt - Extra large icon
        public static var xl: CGFloat { xlAdaptive.value }
        /// 56pt / 72pt - Hero icon
        public static var xxl: CGFloat { xxlAdaptive.value }
    }
    
    // MARK: - Text Size
    /// Font point sizes following SF Pro text styles from Apple HIG.
    /// Usage: `.font(.system(size: Layout.Text.body))`
    public enum Text {
        // SF Pro Text (≤19pt) and SF Pro Display (≥20pt) optical variants
        private static let caption2Adaptive = AdaptiveSize(iPhoneSize: 11, iPadSize: 13)
        private static let caption1Adaptive = AdaptiveSize(iPhoneSize: 12, iPadSize: 14)
        private static let footnoteAdaptive = AdaptiveSize(iPhoneSize: 13, iPadSize: 15)
        private static let subheadlineAdaptive = AdaptiveSize(iPhoneSize: 15, iPadSize: 17)
        private static let calloutAdaptive = AdaptiveSize(iPhoneSize: 16, iPadSize: 18)
        private static let bodyAdaptive = AdaptiveSize(iPhoneSize: 17, iPadSize: 20)
        private static let headlineAdaptive = AdaptiveSize(iPhoneSize: 17, iPadSize: 20)
        private static let title3Adaptive = AdaptiveSize(iPhoneSize: 20, iPadSize: 24)
        private static let title2Adaptive = AdaptiveSize(iPhoneSize: 22, iPadSize: 26)
        private static let title1Adaptive = AdaptiveSize(iPhoneSize: 28, iPadSize: 32)
        private static let largeTitleAdaptive = AdaptiveSize(iPhoneSize: 34, iPadSize: 40)
        private static let extraLargeTitleAdaptive = AdaptiveSize(iPhoneSize: 40, iPadSize: 48)
        
        /// 11pt / 13pt - Caption 2 (Apple HIG minimum readable size)
        public static var caption2: CGFloat { caption2Adaptive.value }
        /// 12pt / 14pt - Caption 1
        public static var caption1: CGFloat { caption1Adaptive.value }
        /// 13pt / 15pt - Footnote
        public static var footnote: CGFloat { footnoteAdaptive.value }
        /// 15pt / 17pt - Subheadline
        public static var subheadline: CGFloat { subheadlineAdaptive.value }
        /// 16pt / 18pt - Callout
        public static var callout: CGFloat { calloutAdaptive.value }
        /// 17pt / 20pt - Body (default reading size)
        public static var body: CGFloat { bodyAdaptive.value }
        /// 17pt / 20pt - Headline (Semibold weight)
        public static var headline: CGFloat { headlineAdaptive.value }
        /// 20pt / 24pt - Title 3
        public static var title3: CGFloat { title3Adaptive.value }
        /// 22pt / 26pt - Title 2
        public static var title2: CGFloat { title2Adaptive.value }
        /// 28pt / 32pt - Title 1
        public static var title1: CGFloat { title1Adaptive.value }
        /// 34pt / 40pt - Large Title
        public static var largeTitle: CGFloat { largeTitleAdaptive.value }
        /// 40pt / 48pt - Extra Large Title (hero text)
        public static var extraLargeTitle: CGFloat { extraLargeTitleAdaptive.value }
    }
    
    // MARK: - Button Size
    /// Button dimensions following Apple HIG touch target guidelines.
    public enum Button {
        private static let heightAdaptive = AdaptiveSize(iPhoneSize: 44, iPadSize: 56)
        private static let largeHeightAdaptive = AdaptiveSize(iPhoneSize: 56, iPadSize: 64)
        private static let smallHeightAdaptive = AdaptiveSize(iPhoneSize: 36, iPadSize: 44)
        private static let minWidthAdaptive = AdaptiveSize(iPhoneSize: 80, iPadSize: 100)
        private static let widthAdaptive = AdaptiveSize(iPhoneSize: 120, iPadSize: 160)
        private static let iconButtonSizeAdaptive = AdaptiveSize(iPhoneSize: 44, iPadSize: 50)
        
        /// 44pt / 56pt - Standard button height (Apple HIG compliant)
        public static var height: CGFloat { heightAdaptive.value }
        /// 56pt / 64pt - Large prominent button height
        public static var largeHeight: CGFloat { largeHeightAdaptive.value }
        /// 36pt / 44pt - Small button height (still meets minimum touch target)
        public static var smallHeight: CGFloat { smallHeightAdaptive.value }
        /// 80pt / 100pt - Minimum button width
        public static var minWidth: CGFloat { minWidthAdaptive.value }
        /// 120pt / 160pt - Standard button width
        public static var width: CGFloat { widthAdaptive.value }
        /// 44pt / 50pt - Icon-only button size
        public static var iconButtonSize: CGFloat { iconButtonSizeAdaptive.value }
    }
    
    // MARK: - List Item
    /// List row heights following Apple HIG standards.
    public enum ListItem {
        private static let compactAdaptive = AdaptiveSize(iPhoneSize: 36, iPadSize: 42)
        private static let standardAdaptive = AdaptiveSize(iPhoneSize: 44, iPadSize: 50)
        private static let largeAdaptive = AdaptiveSize(iPhoneSize: 64, iPadSize: 72)
        private static let extraLargeAdaptive = AdaptiveSize(iPhoneSize: 80, iPadSize: 88)
        
        /// 36pt / 42pt - Compact row height
        public static var compact: CGFloat { compactAdaptive.value }
        /// 44pt / 50pt - Standard row height (Apple HIG compliant)
        public static var standard: CGFloat { standardAdaptive.value }
        /// 64pt / 72pt - Large row with subtitle or image
        public static var large: CGFloat { largeAdaptive.value }
        /// 80pt / 88pt - Extra large row with rich content
        public static var extraLarge: CGFloat { extraLargeAdaptive.value }
    }
    
    // MARK: - Content Width
    /// Maximum content widths for optimal readability.
    public enum ContentWidth {
        /// 672pt - Optimal reading width (approx. 70 characters per line)
        public static let readableMaxWidth: CGFloat = 672
        /// 320pt - Compact content width
        public static let compactMaxWidth: CGFloat = 320
        /// 480pt - Medium content width
        public static let mediumMaxWidth: CGFloat = 480
        /// 840pt - Wide content width
        public static let wideMaxWidth: CGFloat = 840
    }
    
    // MARK: - Animation Duration
    /// Standard animation durations for consistent motion design.
    public enum Animation {
        /// 0.1s - Instant feedback
        public static let instant: CGFloat = 0.1
        /// 0.15s - Fast animation
        public static let fast: CGFloat = 0.15
        /// 0.25s - Standard animation (Apple default)
        public static let standard: CGFloat = 0.25
        /// 0.35s - Slow animation
        public static let slow: CGFloat = 0.35
        /// 0.5s - Very slow animation
        public static let verySlow: CGFloat = 0.5
    }
    
    // MARK: - Stroke Width
    /// Stroke/border widths for lines and outlines.
    public enum StrokeWidth {
        private static let hairlineAdaptive = AdaptiveSize(iPhoneSize: 0.5, iPadSize: 0.5)
        private static let thinAdaptive = AdaptiveSize(iPhoneSize: 1, iPadSize: 1)
        private static let regularAdaptive = AdaptiveSize(iPhoneSize: 1.5, iPadSize: 2)
        private static let thickAdaptive = AdaptiveSize(iPhoneSize: 2, iPadSize: 3)
        private static let boldAdaptive = AdaptiveSize(iPhoneSize: 3, iPadSize: 4)
        
        /// 0.5pt - Hairline (separator lines)
        public static var hairline: CGFloat { hairlineAdaptive.value }
        /// 1pt - Thin stroke
        public static var thin: CGFloat { thinAdaptive.value }
        /// 1.5pt / 2pt - Regular stroke
        public static var regular: CGFloat { regularAdaptive.value }
        /// 2pt / 3pt - Thick stroke
        public static var thick: CGFloat { thickAdaptive.value }
        /// 3pt / 4pt - Bold stroke
        public static var bold: CGFloat { boldAdaptive.value }
    }
    
    // MARK: - Shadow
    /// Shadow configurations for elevation.
    public enum Shadow {
        /// Small shadow radius
        public static let smallRadius: CGFloat = 2
        /// Medium shadow radius
        public static let mediumRadius: CGFloat = 8
        /// Large shadow radius
        public static let largeRadius: CGFloat = 16
        /// Extra large shadow radius
        public static let xlRadius: CGFloat = 24
        
        /// Small shadow offset Y
        public static let smallOffsetY: CGFloat = 1
        /// Medium shadow offset Y
        public static let mediumOffsetY: CGFloat = 4
        /// Large shadow offset Y
        public static let largeOffsetY: CGFloat = 8
    }
    
    // MARK: - Opacity
    /// Standard opacity values for visual hierarchy.
    public enum Opacity {
        /// 0.04 - Subtle overlay
        public static let subtle: CGFloat = 0.04
        /// 0.12 - Light overlay
        public static let light: CGFloat = 0.12
        /// 0.3 - Medium overlay
        public static let medium: CGFloat = 0.3
        /// 0.5 - Semi-transparent
        public static let semiTransparent: CGFloat = 0.5
        /// 0.7 - Heavy overlay
        public static let heavy: CGFloat = 0.7
        /// 0.9 - Almost opaque
        public static let almostOpaque: CGFloat = 0.9
    }
}

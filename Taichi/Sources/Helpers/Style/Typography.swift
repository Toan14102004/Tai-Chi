//
//  Typography.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//
//  Mirrors the named type scale from the Figma "Typography" frame
//  (Inter family; weight/size/line-height per style).
//

import SwiftUI

public enum Typography {
    // MARK: - Inter (Taichi only)

    public static var headlineLarge: Font { FontFamily.Inter.bold.font(size: 32) }
    public static var headlineMedium: Font { FontFamily.Inter.bold.font(size: 24) }
    public static var headlineSmall: Font { FontFamily.Inter.bold.font(size: 22) }

    public static var subtitleLarge: Font { FontFamily.Inter.bold.font(size: 20) }
    public static var subtitleMedium: Font { FontFamily.Inter.medium.font(size: 20) }
    public static var subtitleSmall: Font { FontFamily.Inter.bold.font(size: 16) }

    public static var bodyLarge: Font { FontFamily.Inter.medium.font(size: 16) }
    public static var bodyMedium: Font { FontFamily.Inter.regular.font(size: 16) }
    public static var bodySmall: Font { FontFamily.Inter.regular.font(size: 14) }

    public static var labelLarge: Font { FontFamily.Inter.bold.font(size: 14) }
    public static var labelMedium: Font { FontFamily.Inter.medium.font(size: 14) }
    public static var labelSmall: Font { FontFamily.Inter.regular.font(size: 12) }

    public static var captionLarge: Font { FontFamily.Inter.bold.font(size: 12) }
    public static var captionMedium: Font { FontFamily.Inter.medium.font(size: 12) }
    public static var captionSmall: Font { FontFamily.Inter.medium.font(size: 10) }
}

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let appstore = ImageAsset(name: "appstore")
    internal static let playstore = ImageAsset(name: "playstore")
  }
  internal enum Color {
    internal static let colorTaichi = ColorAsset(name: "ColorTaichi")
    internal static let bgAds = ColorAsset(name: "bgAds")
    internal static let bgCanvas = ColorAsset(name: "bgCanvas")
    internal static let bgPrimary = ColorAsset(name: "bgPrimary")
    internal static let bgSecondary = ColorAsset(name: "bgSecondary")
    internal static let bgPopup = ColorAsset(name: "bg_popup")
    internal static let black = ColorAsset(name: "black")
    internal static let blue = ColorAsset(name: "blue")
    internal static let borderPrimary = ColorAsset(name: "borderPrimary")
    internal static let gray = ColorAsset(name: "gray")
    internal static let grayText = ColorAsset(name: "gray_text")
    internal static let iconSurface = ColorAsset(name: "iconSurface")
    internal static let mainColor = ColorAsset(name: "mainColor")
    internal static let optionBorder = ColorAsset(name: "optionBorder")
    internal static let primary = ColorAsset(name: "primary")
    internal static let rowSelected = ColorAsset(name: "rowSelected")
    internal static let secondPurpleLight = ColorAsset(name: "secondPurpleLight")
    internal static let secondaryColor = ColorAsset(name: "secondaryColor")
    internal static let secondaryTint = ColorAsset(name: "secondaryTint")
    internal static let textBrandPrimary = ColorAsset(name: "textBrandPrimary")
    internal static let textDisable = ColorAsset(name: "textDisable")
    internal static let textNavy = ColorAsset(name: "textNavy")
    internal static let textPrimary = ColorAsset(name: "textPrimary")
    internal static let textSecondary = ColorAsset(name: "textSecondary")
    internal static let textTertiary = ColorAsset(name: "textTertiary")
    internal static let toggleTrackOn = ColorAsset(name: "toggleTrackOn")
    internal static let trackInactive = ColorAsset(name: "trackInactive")
    internal static let white = ColorAsset(name: "white")
  }
  internal enum Icon {
    internal enum Camera {
      internal enum Flash {
        internal static let flashOff = ImageAsset(name: "flashOff")
        internal static let flashOn = ImageAsset(name: "flashOn")
      }
      internal static let crosshair = ImageAsset(name: "crosshair")
    }
    internal enum Commo {
      internal static let arrowLeft = ImageAsset(name: "arrowLeft")
      internal static let arrowRateApp = ImageAsset(name: "arrowRateApp")
      internal static let checkPremium = ImageAsset(name: "checkPremium")
      internal static let checkmark = ImageAsset(name: "checkmark")
      internal static let checkmarkCircle = ImageAsset(name: "checkmarkCircle")
      internal static let circle = ImageAsset(name: "circle")
      internal static let dollarCircle = ImageAsset(name: "dollarCircle")
      internal static let edit = ImageAsset(name: "edit")
      internal static let fire = ImageAsset(name: "fire")
      internal static let icNoads = ImageAsset(name: "icNoads")
      internal static let leafLeft = ImageAsset(name: "leafLeft")
      internal static let leafRight = ImageAsset(name: "leafRight")
      internal static let locked = ImageAsset(name: "locked")
      internal static let plus = ImageAsset(name: "plus")
      internal static let premium = ImageAsset(name: "premium")
      internal static let saleTag = ImageAsset(name: "sale_tag")
      internal static let xmark = ImageAsset(name: "xmark")
      internal static let yourStreak = ImageAsset(name: "yourStreak")
    }
    internal enum Discover {
      internal static let jewelry = ImageAsset(name: "jewelry")
      internal static let lockBlack = ImageAsset(name: "lockBlack")
      internal static let lockWhite = ImageAsset(name: "lockWhite")
      internal static let video = ImageAsset(name: "video")
    }
    internal enum Iap {
      internal static let noAds = ImageAsset(name: "noAds")
      internal static let unlock = ImageAsset(name: "unlock")
    }
    internal enum Language {
      internal static let english = ImageAsset(name: "english")
      internal static let french = ImageAsset(name: "french")
      internal static let germany = ImageAsset(name: "germany")
      internal static let hindi = ImageAsset(name: "hindi")
      internal static let japanese = ImageAsset(name: "japanese")
      internal static let korea = ImageAsset(name: "korea")
      internal static let portuguese = ImageAsset(name: "portuguese")
      internal static let spanish = ImageAsset(name: "spanish")
    }
    internal enum Profile {
      internal static let avatarPlaceholder = ImageAsset(name: "avatarPlaceholder")
      internal static let button = ImageAsset(name: "button")
      internal static let cameraBadge = ImageAsset(name: "cameraBadge")
      internal static let chevronRight = ImageAsset(name: "chevronRight")
      internal static let crownPremium = ImageAsset(name: "crownPremium")
      internal static let fireStreak = ImageAsset(name: "fireStreak")
      internal static let menuInviteFriends = ImageAsset(name: "menuInviteFriends")
      internal static let menuLanguage = ImageAsset(name: "menuLanguage")
      internal static let menuPrivacy = ImageAsset(name: "menuPrivacy")
      internal static let menuProfile = ImageAsset(name: "menuProfile")
      internal static let menuRateUs = ImageAsset(name: "menuRateUs")
      internal static let menuReminder = ImageAsset(name: "menuReminder")
      internal static let menuTerms = ImageAsset(name: "menuTerms")
      internal static let menuWorkoutSettings = ImageAsset(name: "menuWorkoutSettings")
      internal static let playPause = ImageAsset(name: "playPause")
      internal static let plusIcon = ImageAsset(name: "plusIcon")
      internal static let premiumSparkle = ImageAsset(name: "premiumSparkle")
      internal static let radioCircle = ImageAsset(name: "radioCircle")
      internal static let soundWave = ImageAsset(name: "soundWave")
      internal static let tickCircle = ImageAsset(name: "tickCircle")
      internal static let volumeMax = ImageAsset(name: "volumeMax")
      internal static let volumeMin = ImageAsset(name: "volumeMin")
    }
    internal enum ProfileSetup {
      internal static let backChevron = ImageAsset(name: "backChevron")
    }
    internal enum Setting {
      internal static let contact = ImageAsset(name: "contact")
      internal static let happy = ImageAsset(name: "happy")
      internal static let language = ImageAsset(name: "language")
      internal static let premium = ImageAsset(name: "premium")
      internal static let sad = ImageAsset(name: "sad")
      internal static let share = ImageAsset(name: "share")
      internal static let shield = ImageAsset(name: "shield")
      internal static let star = ImageAsset(name: "star")
      internal static let starDisable = ImageAsset(name: "starDisable")
      internal static let starEnable = ImageAsset(name: "starEnable")
      internal static let thankFeedback = ImageAsset(name: "thankFeedback")
    }
    internal static let plan = ImageAsset(name: "plan")
    internal enum TabBar {
      internal enum Normal {
        internal static let discoverNormal = ImageAsset(name: "discoverNormal")
        internal static let planNormal = ImageAsset(name: "planNormal")
        internal static let profileNormal = ImageAsset(name: "profileNormal")
        internal static let progressNormal = ImageAsset(name: "progressNormal")
      }
      internal enum Selected {
        internal static let discoverSelected = ImageAsset(name: "discoverSelected")
        internal static let planSelected = ImageAsset(name: "planSelected")
        internal static let profileSelected = ImageAsset(name: "profileSelected")
        internal static let progressSelected = ImageAsset(name: "progressSelected")
      }
    }
  }
  internal enum Image {
    internal enum Premium {
      internal static let premiumBanner = ImageAsset(name: "premiumBanner")
      internal static let textOverlay = ImageAsset(name: "textOverlay")
    }
    internal enum ProfileSetup {
      internal static let generatingPlanIllustration = ImageAsset(name: "generatingPlanIllustration")
    }
    internal enum Setting {
      internal static let backgroundAvatar = ImageAsset(name: "backgroundAvatar")
      internal static let imageBackground = ImageAsset(name: "imageBackground")
      internal static let noInternet = ImageAsset(name: "noInternet")
    }
    internal static let onboarding2 = ImageAsset(name: "onboarding_2")
    internal static let onboardingHero = ImageAsset(name: "onboarding_hero")
    internal static let paywallBg = ImageAsset(name: "paywall_bg")
    internal static let splashBg = ImageAsset(name: "splash_bg")
    internal static let testimonial1 = ImageAsset(name: "testimonial_1")
    internal static let testimonial2 = ImageAsset(name: "testimonial_2")
    internal static let testimonial3 = ImageAsset(name: "testimonial_3")
    internal static let welcomeBg = ImageAsset(name: "welcome_bg")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var uiColor: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var color: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var uiImage: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var image: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

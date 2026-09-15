# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'Taichi' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Taichi
  pod 'Alamofire', '~> 5.10'
  pod 'KeychainAccess', '~> 4.2'
  pod 'Google-Mobile-Ads-SDK'
  pod 'lottie-ios', '~> 4.5.2'
  pod 'Kingfisher', '~> 7.0'

  # Mediation Adapters (Ví dụ các mạng phổ biến)
  pod 'GoogleMobileAdsMediationFacebook'  # Meta Audience Network
  pod 'GoogleMobileAdsMediationAppLovin'  # AppLovin
  pod 'GoogleMobileAdsMediationUnity'     # Unity Ads
  pod 'LBTATools', :git => 'https://github.com/bhlvoong/LBTATools.git'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'


  # IAP
  pod 'TPInAppReceipt', '~> 3.4'

  pod 'Adjust'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      # The app project uses "Dev"/"Release" instead of "Debug"/"Release", so CocoaPods
      # treats "Dev" as a release-type config by default. Force debug-style compilation
      # for "Dev" so SwiftUI Previews (which require -Onone across the dependency graph) work.
      if config.name == 'Dev'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
        config.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
      end
    end
  end
end

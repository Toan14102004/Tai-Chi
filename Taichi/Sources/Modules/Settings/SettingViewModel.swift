//
//  SettingViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/11/24.
//

import Foundation
import SwiftUI
import MessageUI
import UIKit

extension SettingView {
    class ViewModel: BaseViewModel {
        @Injected var keychainStorage: KeychainStorage
        @Injected var localStorageService: LocalStorageService
        @Injected var analytics: AnalyticsService
        @Injected var adsManager: AdsManager
        @Navigation var navigation

        @Published var coordinator = Coordinator()
        @Published var isShowUnlimitedPopup: Bool = false
        @Published var showRatePopup: Bool = false
        @Published var selectedRating: Int = 0
        @Published var showFeedback: Bool = false
        @Published var selectedFeedbackReasons: Set<String> = []
        @Published var otherFeedbackText: String = ""
        @Published var showThankYou: Bool = false
        
        private var isMailAvailable: Bool {
            return MFMailComposeViewController.canSendMail()
        }
        
        func goBack() {
            navigation.pop()
        }

        func openPremiumView() {
            analytics.logEvent(name: "PW_Settings_banner_impression")
            navigation.presentCover(RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .settings), withNavigation: true)
        }

        func navigateToLanguage() {
            navigation.push(Coordinator.Navigation.language)
        }
        
        func openRateUs() {
            selectedRating = 0
            showRatePopup = true
        }
        
        func submitRating() {
            if selectedRating >= 4 {
                // open AppStore review
                let appId = AppConfiguration.appId
                let urlString = "https://apps.apple.com/app/id\(appId)?action=write-review"
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
                showRatePopup = false
            } else if selectedRating > 0 {
                // show feedback form
                showRatePopup = false
                
                // delay để tắt popup
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.showFeedback = true
                }
            }
        }
        
        func sendFeedback() {
            let reasons = selectedFeedbackReasons.joined(separator: ", ")
            if selectedFeedbackReasons.contains("Others") && !otherFeedbackText.isEmpty {
                print("Feedback sent: \(reasons) - Other: \(otherFeedbackText)")
            } else {
                print("Feedback sent: \(reasons)")
            }
            
            showFeedback = false
            
            // delay to allow current popup to dismiss before showing thank you
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self = self else { return }
                
                // reset lại state
                self.selectedFeedbackReasons = []
                self.otherFeedbackText = ""
                self.selectedRating = 0
                
                // show thank you popup
                self.showThankYou = true
                
                // auto dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.showThankYou = false
                }
            }
        }
        
        func shareApp() {
            let appId = AppConfiguration.appId
            let appURL = "https://apps.apple.com/app/\(appId)"
            openShareView([appURL])
        }
        
        func openFeedback() {
            if isMailAvailable {
                navigation.presentSheet(Coordinator.FullScreen.feedback)
            } else {
                navigation.push(Coordinator.Navigation.feedback)
            }
        }
        
        func onMailSentSuccess(data: MFMailComposeResult) {
            coordinator.alert = .success(title: "Send mail success", message: "")
        }
        
        func onMailSentError(error: Error) {
            coordinator.alert = .error(title: "Send mail error", message: error.localizedDescription)
        }
        
        func openPrivacyPolicy() {
            let privacyUrlString = AppConfiguration.privacyUrl
            if let url = URL(string: privacyUrlString) {
                UIApplication.shared.open(url)
            }
        }
        
        func openTermOfUse() {
            let termOfUseUrlString = AppConfiguration.termOfUseUrl
            if let url = URL(string: termOfUseUrlString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

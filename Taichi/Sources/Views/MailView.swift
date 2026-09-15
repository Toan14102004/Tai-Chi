//
//  MailView.swift
//  Taichi
//
//  Created by Toan Nguyen on 15/10/25.
//

import Foundation
import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    
    var onSuccess: ((MFMailComposeResult) -> Void)?
    var onError: ((Error) -> Void)?
    var onDismiss: (() -> Void)?
    
    var appVersion: String {
        let _version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return _version ?? ""
    }
    
    var locale: Locale = .current
    var appName: String { AppConfiguration.appName }
    var messageFeedback: String = """
        <h1>THANK YOU</h1>
        <p>Please describe your problem by replying to this email, if possible with the screenshot</p>
        """

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        var onSuccess: ((MFMailComposeResult) -> Void)?
        var onError: ((Error) -> Void)?
        var onDismiss: (() -> Void)?

        init(presentation: Binding<PresentationMode>,
             onSuccess: ((MFMailComposeResult) -> Void)?,
             onError: ((Error) -> Void)?,
             onDismiss: (() -> Void)?) {
            _presentation = presentation
            self.onSuccess = onSuccess
            self.onError = onError
            self.onDismiss = onDismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
                onDismiss?()
            }
            
            if let error = error {
                onError?(error)
                return
            }
            
            onSuccess?(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                          onSuccess: onSuccess,
                          onError: onError,
                          onDismiss: onDismiss)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        vc.setToRecipients([AppConfiguration.emailFeedback])
        vc.setSubject("Help with \(appName) (\(appVersion)) - Feedback \(UUID().uuidString) from \(UIDevice.current.name) of iOS Version-\(UIDevice.current.systemVersion) \(locale.identifier)")
        vc.setMessageBody(messageFeedback, isHTML: true)
        
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        // No updates needed
    }
}

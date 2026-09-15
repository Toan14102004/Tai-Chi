//
//  YouTubePlayerView.swift
//  Taichi
//
//  Created by Toan Nguyen on 9/10/25.
//

import Foundation
import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context _: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        // Extract video ID if full URL is provided
        let cleanedVideoID = extractVideoID(from: videoID)
        
        // Get bundle ID for referrer
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let referrer = "https://\(bundleId)"
        
        // Build embed URL with parameters
        let embedURL = "https://www.youtube.com/embed/\(cleanedVideoID)?autoplay=1&controls=0&showinfo=0&playsinline=1&modestbranding=1&rel=0&enablejsapi=1&origin=\(referrer)"
        
        // Create HTML with iframe and set referrer policy
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <meta name="referrer" content="no-referrer">
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          html, body {
            margin: 0;
            padding: 0;
            background-color: black;
            height: 100%;
            width: 100%;
            overflow: hidden;
          }
          .video-container {
            position: relative;
            width: 100%;
            height: 100%;
            background-color: black;
          }
          .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
          }
        </style>
        </head>
        <body>
          <div class="video-container">
            <iframe
              id="youtube-player"
              src="\(embedURL)"
              frameborder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen
              webkitallowfullscreen
              mozallowfullscreen
              referrerpolicy="strict-origin-when-cross-origin">
            </iframe>
          </div>
        </body>
        </html>
        """
        
        // Load HTML with base URL to set referrer context
        uiView.loadHTMLString(html, baseURL: URL(string: referrer))
    }
    
    // MARK: - Helper Methods
    
    private func extractVideoID(from input: String) -> String {
        // If it's already a clean video ID, return it
        if !input.contains("youtube.com") && !input.contains("youtu.be") {
            return input
        }
        
        // Extract from full YouTube URL
        let patterns = [
            "youtube.com/watch\\?v=([^&]+)",
            "youtu.be/([^?]+)",
            "youtube.com/embed/([^?]+)",
            "youtube.com/v/([^?]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
               let range = Range(match.range(at: 1), in: input) {
                return String(input[range])
            }
        }
        
        return input
    }
}

#Preview(body: {
    YouTubePlayerView(videoID: "-HAi_5IIAYg")
        .aspectRatio(16 / 9, contentMode: .fit)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
})

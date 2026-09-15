//
//  RemoteImageView.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import Kingfisher
import SwiftUI

/// Photos served by the Taichi API (`upload-services.limgrow.com`, mostly `.webp`).
/// Unlike `GithubImageView` this sends no auth header and applies no corner radius of its own --
/// callers clip it, so the same view works for hero images, cards, and list thumbnails.
struct RemoteImageView: View {
    let url: URL?
    var contentMode: SwiftUI.ContentMode = .fill

    @State private var hasFailed = false

    var body: some View {
        Group {
            if let url, !hasFailed {
                KFImage(url)
                    .placeholder { placeholder }
                    .backgroundDecode(true)
                    .fade(duration: 0.2)
                    .onFailure { _ in hasFailed = true }
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var placeholder: some View {
        Asset.Color.bgSecondary.color
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Asset.Color.textSecondary.color.opacity(Layout.Opacity.medium))
            }
    }
}

//
//  GithubImageView.swift
//  Wallpaper
//
//  Created by Toan Nguyen on 27/10/25.
//

import Kingfisher
import SwiftUI

struct GithubImageView: View {
  @Injected var gitHubDataService: GitHubDataService

  var shortPath: String
  var contentMode: SwiftUI.ContentMode = .fit
  var targetSize: CGSize? = nil
  @State private var hasFailedToLoad = false

  var body: some View {
    Group {
      if let url = gitHubDataService.getImageURL(for: shortPath) {
        if hasFailedToLoad {
          Image(systemName: "photo.badge.exclamationmark")
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .foregroundColor(.gray)
        } else {
          let scale = UIScreen.main.scale
          let processor = targetSize.map {
            DownsamplingImageProcessor(
              size: CGSize(width: $0.width * scale, height: $0.height * scale))
          }
          KFImage(url)
            .requestModifier { request in
              let token = gitHubDataService.githubToken
              request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            .placeholder {
              ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .setProcessor(processor ?? DefaultImageProcessor.default)
            // .cacheOriginalImage(true) // Disable to cache processed (downsampled) image for performance
            .scaleFactor(scale)
            .backgroundDecode(true)
            .fade(duration: 0.2)
            .onFailure { _ in
              hasFailedToLoad = true
            }
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .cornerRadius(radius: Layout.CornerRadius.medium, corners: .allCorners)
            .clipped()
        }
      } else {
        Image(systemName: "photo.badge.exclamationmark")
          .resizable()
          .aspectRatio(contentMode: contentMode)
          .foregroundColor(.gray)
      }
    }
  }
}

#Preview {
  VStack {
    // Default (scaledToFit)
    GithubImageView(shortPath: "category/test.png", contentMode: .fit)
      .frame(width: 300, height: 300)

    // Scaled to fill
    GithubImageView(shortPath: "category/test.png", contentMode: .fill)
      .frame(width: 300, height: 300)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

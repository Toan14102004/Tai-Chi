//
//  LocalImageView.swift
//  Taichi
//
//  Created by Toan Nguyen on 12/9/25.
//

import SwiftUI
import UIKit

struct LocalImageView: View {
    let shortPath: String
    let placeholder: String?
    let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var hasError: Bool = false

    init(shortPath: String, placeholder: String? = nil, contentMode: ContentMode = .fit) {
        self.shortPath = shortPath
        self.placeholder = placeholder
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if hasError {
                errorView
            } else if isLoading {
                loadingView
            } else {
                placeholderView
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private var errorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Failed to load image")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.title2)
                .foregroundColor(.secondary)
            if let placeholder {
                Text(placeholder)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fullURL = URL.documentUrl.appendingPathComponent(shortPath)

            guard FileManager.default.fileExists(atPath: fullURL.path) else {
                DispatchQueue.main.async {
                    hasError = true
                    isLoading = false
                }
                return
            }

            guard let imageData = try? Data(contentsOf: fullURL),
                  let loadedImage = UIImage(data: imageData) else {
                DispatchQueue.main.async {
                    hasError = true
                    isLoading = false
                }
                return
            }

            DispatchQueue.main.async {
                image = loadedImage
                isLoading = false
            }
        }
    }
}

// MARK: - Convenience Initializers

extension LocalImageView {
    /// Create a LocalImageView with a specific size
    static func sized(
        shortPath: String,
        width: CGFloat,
        height: CGFloat,
        contentMode: ContentMode = .fit
    ) -> some View {
        LocalImageView(shortPath: shortPath, contentMode: contentMode)
            .frame(width: width, height: height)
    }

    /// Create a LocalImageView for thumbnail display
    static func thumbnail(shortPath: String, size: CGFloat = 60) -> some View {
        LocalImageView(shortPath: shortPath, contentMode: .fill)
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(8)
    }

    /// Create a LocalImageView for full-screen display
    static func fullScreen(shortPath: String) -> some View {
        LocalImageView(shortPath: shortPath, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Thumbnail example
        LocalImageView.thumbnail(shortPath: "Image Folder/sample.jpg")

        // Sized example
        LocalImageView.sized(shortPath: "Image Folder/sample.jpg", width: 200, height: 150)

        // Error example (non-existent file)
        LocalImageView(shortPath: "non-existent.jpg", placeholder: "No image")
    }
    .padding()
}

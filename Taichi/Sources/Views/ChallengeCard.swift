//
//  ChallengeCard.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The "Challenge" carousel card: cover photo across the top, then the title and a footer pairing
/// the participant cluster with the Join CTA.
///
/// Metrics from Figma `2306:6247` → `card_ challenge`: 224×186 at r16, photo 224×120 rounded on
/// its top corners only, content inset 8pt with a 16pt bottom.
///
/// `avatarUrls` and `participantsText` are optional because the API serves neither — no Discover
/// endpoint returns a participant count or member avatars. When they are nil the footer falls back
/// to the workout's own duration/exercise line, which is real data, and the CTA keeps its place.
struct ChallengeCard: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    var avatarUrls: [URL] = []
    var participantsText: String?
    let buttonTitle: String
    let action: () -> Void

    static let cardWidth: CGFloat = 224
    static let cardSpacing: CGFloat = 16

    private static let photoHeight: CGFloat = 120
    private static let cardHeight: CGFloat = 186

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth, height: Self.photoHeight)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .lineLimit(1)

                footer
            }
            .padding(.horizontal, Layout.Spacing.s)
            .padding(.top, Layout.Spacing.s)
            .padding(.bottom, Layout.Spacing.m)
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight, alignment: .topLeading)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var footer: some View {
        HStack(spacing: 7) {
            if !avatarUrls.isEmpty {
                AvatarStack(urls: avatarUrls)
            }

            Text(participantsText ?? subtitle)
                .font(Typography.labelSmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: Layout.Spacing.xs)

            Button(action: action) {
                Text(buttonTitle)
                    .font(Typography.captionSmall)
                    .foregroundStyle(Asset.Color.white.color)
                    .padding(.horizontal, Layout.Spacing.s)
                    .padding(.vertical, Layout.Spacing.xs)
                    .background(Asset.Color.mainColor.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
}

/// Overlapping circular avatars, as the design shows next to the participant count.
struct AvatarStack: View {
    let urls: [URL]
    var diameter: CGFloat = 20
    var maximum: Int = 3

    var body: some View {
        HStack(spacing: -7) {
            ForEach(Array(urls.prefix(maximum).enumerated()), id: \.offset) { _, url in
                RemoteImageView(url: url)
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Asset.Color.white.color, lineWidth: 1))
            }
        }
    }
}

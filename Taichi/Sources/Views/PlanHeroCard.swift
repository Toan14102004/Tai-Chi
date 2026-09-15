//
//  PlanHeroCard.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct PlanHeroCard: View {
    let imageUrl: URL?
    let title: String
    let durationText: String?
    let exercisesText: String?
    let buttonTitle: String
    let action: () -> Void

    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 210
    static let cardSpacing: CGFloat = 16

    var body: some View {
        Button(action: action) {
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .overlay { PhotoCardScrim(startLocation: 0.45) }
                .overlay(alignment: .bottomLeading) { content }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(FontFamily.Inter.semiBold.font(size: 20))
                    .frame(height: 28)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if let durationText, let exercisesText {
                    HStack(spacing: 9) {
                        Text(durationText)
                        Text(exercisesText)
                    }
                    .font(Typography.labelSmall)
                    .frame(height: 16)
                }
            }
            .foregroundStyle(Asset.Color.white.color)

            CardStartButtonLabel(title: buttonTitle)
        }
        .padding(.horizontal, 17.5)
        .padding(.bottom, 10)
    }
}

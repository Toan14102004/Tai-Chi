//
//  SoundWaveAnimation.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// A 5-bar sound wave that bounces for as long as it's on screen. Callers swap it in for
/// `Asset.Icon.Profile.soundWave` (the static icon) based on `BackgroundMusicPlayer.isPlaying` --
/// the animation itself doesn't know or care why it's showing.
struct SoundWaveAnimation: View {
    @State private var isAnimating = false

    private let barHeights: [CGFloat] = [8, 16, 11, 20, 13]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(barHeights.indices, id: \.self) { index in
                Capsule()
                    .fill(Asset.Color.mainColor.color)
                    .frame(width: 3, height: isAnimating ? barHeights[index] : 5)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.08),
                        value: isAnimating
                    )
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
        .accessibilityElement(children: .ignore)
    }
}

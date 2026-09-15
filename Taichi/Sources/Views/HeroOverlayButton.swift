//
//  HeroOverlayButton.swift
//  Taichi
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// Small circular button floating over a hero photo — back/close/settings on the
/// Schedule, Workout Day, and Exercise Detail screens.
struct HeroOverlayButton: View {
    let image: ImageAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            image.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Asset.Color.white.color)
                .padding(4)
                .background(.black.opacity(0.4))
                .clipShape(Circle())
        }
    }
}

/// The settings button on the hero, matching `HeroOverlayButton`'s 32pt circle. Draws an SF
/// Symbol because the design's gear has not been exported from Figma yet — image export is on a
/// tighter REST quota than the file read, so it is still pending.
struct HeroOverlaySettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Asset.Color.white.color)
                .frame(width: 24, height: 24)
                .padding(4)
                .background(.black.opacity(0.4))
                .clipShape(Circle())
        }
    }
}

//
//  NoInternetView.swift
//  Taichi
//

import SwiftUI

/// Full-screen replacement for the whole app while `NetworkMonitor` reports no connectivity --
/// every tab depends on the API, so there's nothing useful to show underneath it.
struct NoInternetView: View {
    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            Asset.Image.Setting.noInternet.image
                .resizable()
                .scaledToFit()

            VStack(spacing: Layout.Spacing.xs) {
                Text("Whoops!!")
                    .font(FontFamily.Inter.medium.font(size: Layout.Text.title3))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .multilineTextAlignment(.center)

                Text("No internet connection was found. Check your connection or try again.")
                    .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: Layout.Spacing.s) {
                Button {
                    NetworkMonitor.shared.recheck()
                } label: {
                    Text("Try again")
                        .font(FontFamily.Inter.medium.font(size: Layout.Text.body))
                        .foregroundStyle(Asset.Color.white.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Spacing.s)
                        .background(Capsule().fill(Asset.Color.mainColor.color))
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Go to settings")
                        .font(FontFamily.Inter.medium.font(size: Layout.Text.body))
                        .foregroundStyle(Asset.Color.textBrandPrimary.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Spacing.s)
                        .overlay(Capsule().stroke(Asset.Color.textBrandPrimary.color, lineWidth: 1))
                }
            }
        }
        .padding(.horizontal, Layout.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NoInternetView()
        .preview()
}

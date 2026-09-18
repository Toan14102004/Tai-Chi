//
//  WelcomeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Group {
            VStack(spacing: 0) {
                Spacer()

                Text("Your Tai Chi Journey Starts Here")
                    .font(FontFamily.Inter.bold.font(size: 24))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 33)
                    .padding(.bottom, 31)

                PrimaryButton(title: "Get Started", systemIcon: nil, action: viewModel.getStarted)
                    .frame(width: 177)
            }
            .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.l)
        }
        .foregroundStyle(.white)
        .colorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Asset.Image.welcomeBg.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.2))
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen("welcomeVC")
    }
}

#Preview {
    WelcomeView(viewModel: .init())
        .preview()
}

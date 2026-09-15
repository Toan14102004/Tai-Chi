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
                
                HStack(spacing: 10) {
                    Asset.Icon.Commo.leafLeft.image
                        .toIcon(Layout.Icon.xxl)

                    VStack(alignment: .center, spacing: 0) {
                        Text("1.000.000+")
                            .font(FontFamily.Inter.bold.font(size: 16))
                        Text("Download the App")
                            .font(FontFamily.Inter.regular.font(size: 14))
                        HStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(Color(hex: "F9BF01"))
                            }
                        }
                    }

                    Asset.Icon.Commo.leafRight.image
                        .toIcon(Layout.Icon.xxl)
                }
                .padding(.bottom, Layout.Spacing.m)

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

//
//  OnboardingView.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject private var languageManager = LanguageManager.shared

    private func localized(_ key: String) -> String {
        key.localizedString
    }

    private func localizedAttributedHeadline(_ page: OnboardingPage) -> AttributedString {
        _ = languageManager.currentLanguageCode
        var text = AttributedString(localized(page.headline))
        text.foregroundColor = Asset.Color.textPrimary.color
        for phraseKey in page.highlights {
            if let range = text.range(of: localized(phraseKey)) {
                text[range].foregroundColor = Asset.Color.secondaryColor.color
            }
        }
        return text
    }

    /// Two 32pt headline lines plus the 24pt gap above the page dots.
    private static let photoHeadlineHeight: CGFloat = 88

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPage) {
                ForEach(viewModel.pages) { page in
                    pageContent(page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentPage)
            .background {
                // TabView(.page) clips its page content to the safe area regardless of
                // `.ignoresSafeArea`, so the photo can't bleed under the status bar from inside
                // a page. Rendering it as a background behind the TabView instead, sized to
                // just the TabView (not the footer below it).
                Group {
                    if let photo = viewModel.pages[viewModel.currentPage].photo {
                        photoBackground(photo)
                            .id(viewModel.currentPage)
                            .transition(.opacity)
                    } else {
                        Asset.Color.bgPrimary.color
                    }
                }
                .animation(.easeInOut, value: viewModel.currentPage)
                .ignoresSafeArea(edges: .top)
            }

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .colorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .trackScreen("onboardingVC")
    }

    @ViewBuilder
    private func pageContent(_ page: OnboardingPage) -> some View {
        if page.photo != nil {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                headline(page)
                    .frame(height: Self.photoHeadlineHeight, alignment: .top)
            }
        } else {
            testimonialsPage(page)
        }
    }

    private func photoBackground(_ photo: ImageAsset) -> some View {
        VStack(spacing: 0) {
            Color.clear
                .overlay(alignment: .top) {
                    photo.image
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .overlay(alignment: .bottom) { bottomFade.frame(height: 214) }

            Asset.Color.bgPrimary.color
                .frame(height: Self.photoHeadlineHeight)
        }
    }

    private var bottomFade: some View {
        LinearGradient(
            colors: [Asset.Color.bgPrimary.color.opacity(0), Asset.Color.bgPrimary.color],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func headline(_ page: OnboardingPage) -> some View {
        Text(localizedAttributedHeadline(page))
            .font(FontFamily.Inter.bold.font(size: 24))
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Layout.Spacing.m)
    }

    private func testimonialsPage(_ page: OnboardingPage) -> some View {
        VStack(alignment: .leading, spacing: 25) {
            headline(page)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.testimonials) { testimonial in
                        testimonialCard(testimonial)
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, UIApplication.shared.safeAreaTop + 33)
    }

    private func testimonialCard(_ testimonial: OnboardingTestimonial) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            testimonial.image.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 279, height: 217)
                .clipped()

            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                HStack(spacing: 2) {
                    Text(testimonial.name)
                        .font(FontFamily.Inter.medium.font(size: 14))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Color(hex: "F9BF01"))
                        }
                    }
                }
                Text(localized(testimonial.quote))
                    .font(FontFamily.Inter.regular.font(size: 12))
                    .lineSpacing(1)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 0)
        }
        .padding(.bottom, Layout.Spacing.m)
        .frame(width: 279, height: 321, alignment: .top)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var footer: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(viewModel.pages) { page in
                    Capsule()
                        .fill(page.id == viewModel.currentPage ? Asset.Color.mainColor.color : Color(hex: "A1ADBC"))
                        .frame(width: page.id == viewModel.currentPage ? 29 : 8, height: 8)
                }
            }
            .animation(.easeInOut, value: viewModel.currentPage)

            Spacer()

            Button(action: viewModel.next) {
                Text(viewModel.isLastPage ? localized("onboarding.action.get_started") : localized("onboarding.action.next"))
                    .font(FontFamily.Inter.medium.font(size: 16))
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
        }
        .padding(Layout.Spacing.m)
        .padding(.bottom, UIApplication.shared.safeAreaBottom)
    }
}

#Preview {
    OnboardingView(viewModel: .init())
        .preview()
}

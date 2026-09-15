//
//  OnboardingViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 20/8/26.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
    /// Localization keys for phrases inside `headline` drawn in the secondary green.
    let highlights: [String]
    /// Full-bleed photo behind the page; `nil` for the testimonials page.
    let photo: ImageAsset?
}

struct OnboardingTestimonial: Identifiable {
    let id = UUID()
    let name: String
    let quote: String
    let image: ImageAsset
}

extension OnboardingView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator

        @Published var coordinator = Coordinator()
        @Published var currentPage: Int = 0

        let pages: [OnboardingPage] = [
            OnboardingPage(
                id: 0,
                headline: "onboarding.headline.relax",
                highlights: ["onboarding.highlight.relax_breathe", "onboarding.highlight.balance"],
                photo: Asset.Image.onboardingHero
            ),
            OnboardingPage(
                id: 1,
                headline: "onboarding.headline.improve",
                highlights: ["onboarding.highlight.balance", "onboarding.highlight.at_home"],
                photo: Asset.Image.onboarding2
            ),
            OnboardingPage(
                id: 2,
                headline: "onboarding.headline.join_community",
                highlights: ["onboarding.highlight.people"],
                photo: nil
            ),
        ]

        let testimonials: [OnboardingTestimonial] = [
            OnboardingTestimonial(
                name: "Maria Jane",
                quote: "onboarding.testimonial.maria",
                image: Asset.Image.testimonial1
            ),
            OnboardingTestimonial(
                name: "Jennie",
                quote: "onboarding.testimonial.jennie",
                image: Asset.Image.testimonial2
            ),
            OnboardingTestimonial(
                name: "Anna",
                quote: "onboarding.testimonial.anna",
                image: Asset.Image.testimonial3
            ),
        ]

        var isLastPage: Bool { currentPage == pages.count - 1 }

        func next() {
            if isLastPage {
                navigator.push(RootView.Coordinator.Navigation.profileSetup)
            } else {
                currentPage += 1
            }
        }
    }
}

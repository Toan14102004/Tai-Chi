//
//  DiscoverHomeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

struct DiscoverHomeView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if viewModel.isLoading, !viewModel.hasLoaded {
                    // No outer padding here: DiscoverHomeSkeletonView already pads each section
                    // itself, same as the real content below it -- adding it again here would
                    // double it up (32pt instead of 16pt) and misalign the skeleton.
                    DiscoverHomeSkeletonView()
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                    WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                        .padding(.horizontal, Layout.Spacing.m)
                } else {
                    recentSection

                    PreloadedNativeAdsView(adKey: .discoverCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)
                        .padding(.horizontal, Layout.Spacing.m)

                    recentWorkoutsCarousel

                    ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                        sectionCarousel(section)

                        // The design's second native ad sits after the first two category
                        // sections (08-discover.md, node 4085:7506) -- a separate ad key from the
                        // one above so it loads its own NativeAd rather than reusing that one.
                        if index == 1 {
                            PreloadedNativeAdsView(adKey: .discoverCompactSecondary,
                                                   style: .contentCard,
                                                   height: NativeAdViewStyle.contentCard.height)
                                .padding(.horizontal, Layout.Spacing.m)
                        }
                    }
                }
            }
            // Clears the 64 pt tab bar that ContentView overlays on the bottom edge.
            .padding(.bottom, 64 + Layout.Spacing.m)
        }
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("discoverHomeVC")
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentSection: some View {
        // Hidden outright until a plan is under way: the design has no empty state for it, and an
        // empty card would sit above the fold on a first run.
        if let plan = viewModel.recentPlan {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderRow(title: "Recent")

                RecentPlanCard(
                    imageUrl: viewModel.recentDay?.imageUrl ?? plan.coverImageUrl,
                    title: plan.title,
                    subtitle: viewModel.recentSubtitle,
                    progress: viewModel.recentProgress,
                    action: viewModel.openRecentPlan
                )
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
    }

    // MARK: - Recently practised

    @ViewBuilder
    private var recentWorkoutsCarousel: some View {
        // Untitled in the design; hidden until the user has practised something.
        if !viewModel.recentWorkouts.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DiscoverFeaturedCard.cardSpacing) {
                    ForEach(viewModel.recentWorkouts) { workout in
                        DiscoverFeaturedCard(workout: workout) {
                            viewModel.openWorkout(workout)
                        }
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
            }
        }
    }

    // MARK: - Sections

    private func sectionCarousel(_ section: DiscoverSection) -> some View {
        // No "View all" link: the Tai Chi design's section headers are titles only.
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: section.title)
                .padding(.horizontal, Layout.Spacing.m)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: DiscoverWorkoutCard.cardSpacing) {
                    ForEach(section.items) { workout in
                        DiscoverWorkoutCard(workout: workout) {
                            viewModel.openWorkout(workout)
                        }
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
            }
        }
    }
}

#Preview {
    DiscoverHomeView()
        .preview()
}

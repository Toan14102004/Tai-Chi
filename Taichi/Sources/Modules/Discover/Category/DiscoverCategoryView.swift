//
//  DiscoverCategoryView.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Every workout in one Discover section -- the "View all" screen behind a carousel header.
struct DiscoverCategoryView: View {
    @StateObject private var viewModel: ViewModel

    init(category: String, title: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(category: category, title: title))
    }

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: viewModel.title, back: viewModel.back)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    if viewModel.paging.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.paging.items) { workout in
                            DiscoverListCard(workout: workout) {
                                viewModel.openWorkout(workout)
                            }
                            .onAppear { viewModel.loadMoreIfNeeded(reaching: workout) }
                        }

                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.m)
            }

            // Pinned rather than threaded through the cards, so it stays put while the list scrolls.
            PreloadedNativeAdsView(adKey: .discoverCompact,
                                   style: .contentCard,
                                   height: NativeAdViewStyle.contentCard.height)
                .padding(.horizontal, Layout.Spacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("discoverCategoryVC")
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.isLoading {
            DiscoverCategorySkeletonView()
        } else if let errorMessage = viewModel.errorMessage {
            WorkoutErrorView(message: errorMessage, retry: viewModel.load)
        }
    }
}

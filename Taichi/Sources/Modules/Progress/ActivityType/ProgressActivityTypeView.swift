//
//  ProgressActivityTypeView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Figma `04 / Activity — Select Type` (2160:3392).
//

import SwiftUI

struct ProgressActivityTypeView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: "Add Activity", back: viewModel.back)

            if viewModel.isLoading, viewModel.categories.isEmpty {
                ProgressActivityTypeSkeletonView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.categories.isEmpty {
                WorkoutErrorView(message: errorMessage, retry: viewModel.load)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.categories) { category in
                            row(category)
                        }

                        PreloadedNativeAdsView(adKey: .discoverCompact,
                                               style: .contentCard,
                                               height: NativeAdViewStyle.contentCard.height)
                            .padding(.top, Layout.Spacing.m)
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("progressActivityTypeVC")
    }

    private func row(_ category: ProgressCategory) -> some View {
        Button { viewModel.open(category) } label: {
            HStack(spacing: Layout.Spacing.m) {
                Image(systemName: category.systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Asset.Color.secondaryColor.color)
                    .frame(width: 40.iPad(45),height: 36.iPad(39))
                    .background(Asset.Color.secondPurpleLight.color)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.small))

                Text(category.name)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }
            .padding(.vertical, Layout.Spacing.s)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Asset.Color.borderPrimary.color.frame(height: 1)
        }
    }
}

//
//  ProfileSetupView.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.currentStep == .generatingPlan {
                GeneratingPlanStepView(errorMessage: viewModel.registrationError, retry: viewModel.submitProfile)
            } else {
                VStack(spacing: 0) {
                    header
                        .padding(.top, Layout.Spacing.m)

                    ScrollView {
                        VStack(spacing: 0) {
                            stepContent
                                .padding(.vertical, Layout.Spacing.l)

                            footer
                                .padding(.top, Layout.Spacing.xl)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .colorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
        .trackScreen("profileSetupVC")
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            HStack(spacing: Layout.Spacing.s) {
                Button(action: viewModel.back) {
                    Asset.Icon.ProfileSetup.backChevron.image
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                progressBar

                Text(viewModel.progressLabel)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .fixedSize()
            }
            .padding(.horizontal, Layout.Spacing.m)

            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                Text(viewModel.currentStep.title.localizedKey)
                    .font(Typography.headlineMedium)
                    .lineSpacing(3)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Layout.Spacing.m)

                if let subtitle = viewModel.currentStep.subtitle {
                    Text(subtitle.localizedKey)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
        }
        .padding(.top, Layout.Spacing.xs)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Asset.Color.borderPrimary.color)
                Capsule()
                    .fill(Asset.Color.mainColor.color)
                    .frame(width: geometry.size.width * viewModel.progressFraction)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        let step = viewModel.currentStep
        switch step {
        case .height:
            HeightStepView(viewModel: viewModel)
        case .weight:
            WeightStepView(viewModel: viewModel, text: $viewModel.currentWeightText, type: .current)
        case .targetWeight:
            WeightStepView(viewModel: viewModel, text: $viewModel.targetWeightText, type: .target)
        case .age:
            AgeStepView(viewModel: viewModel)
        case .displayName:
            NameStepView(viewModel: viewModel)
        case .generatingPlan:
            EmptyView()
        default:
            if let keyPath = step.multiAnswer {
                SelectOptionsStepView(
                    options: step.options,
                    isSelected: { viewModel.isSelected($0, in: keyPath) },
                    onSelect: { viewModel.toggleMulti($0, exclusiveWith: step.exclusiveValue, for: keyPath) }
                )
            } else if let keyPath = step.singleAnswer {
                SelectOptionsStepView(
                    options: step.options,
                    isSelected: { viewModel.isSelected($0, in: keyPath) },
                    onSelect: { viewModel.selectSingle($0, for: keyPath) }
                )
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: Layout.Spacing.s) {
            if let adKey = viewModel.currentStep.compactAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .banner, height: NativeAdViewStyle.banner.height)
                    .padding(.horizontal, Layout.Spacing.m)
            }
            if let adKey = viewModel.currentStep.mediumAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .medium, height: NativeAdViewStyle.medium.height)
                    .padding(.horizontal, Layout.Spacing.m)
            }

            Button(action: viewModel.next) {
                Text("Next")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.isNextEnabled ? Asset.Color.mainColor.color : Asset.Color.gray.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isNextEnabled)
            .padding(.horizontal, 40)
        }
        .padding(.top, Layout.Spacing.m)
        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }
}

#Preview {
    ProfileSetupView(viewModel: .init())
        .preview()
}

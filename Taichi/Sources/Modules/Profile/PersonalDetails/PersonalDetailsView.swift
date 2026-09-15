//
//  PersonalDetailsView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Figma: FLow Profile / 02 — Personal Details (03 is the system photo picker).
struct PersonalDetailsView: View {
    @StateObject var viewModel = ViewModel()
    @State private var nameDraft: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: "profile.row.my_profile".localizedString, onBack: viewModel.back)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    avatar
                    nameField
                    measurements

                    PreloadedNativeAdsView(adKey: .profileMedium, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.load()
            nameDraft = viewModel.profile.displayName
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            // Figma: FLow Profile / 03 — the system photo picker, presented as-is.
            ImagePicker { images in
                guard let image = images.first else { return }
                viewModel.setAvatar(image)
            }
        }
        .trackScreen("personalDetailsVC")
    }

    // MARK: - Pieces

    private var avatar: some View {
        Group {
            if let image = viewModel.avatarImage {
                Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
            } else {
                Asset.Icon.Profile.avatarPlaceholder.image.resizable().aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
            Button {
                viewModel.isShowingImagePicker = true
            } label: {
                Asset.Icon.Profile.cameraBadge.image
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(Layout.Spacing.xs)
                    .background(Asset.Color.secondaryColor.color)
                    .clipShape(Circle())
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            Text("Name")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)

            TextField("Name", text: $nameDraft)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .padding(Layout.Spacing.m)
                .frame(height: 52)
                .background(Asset.Color.white.color)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
                .onSubmit { viewModel.commitName(nameDraft) }
                .onChange(of: nameDraft) { viewModel.commitName($0) }
        }
    }

    private var measurements: some View {
        VStack(spacing: Layout.Spacing.l) {
            unitToggle

            VStack(spacing: 0) {
                measurementRow("Height", value: viewModel.heightText)
                measurementRow("Weight", value: viewModel.weightText)
                measurementRow("Target Weight", value: viewModel.targetWeightText)
            }
        }
        .padding(.top, Layout.Spacing.m)
        .padding(.horizontal, Layout.Spacing.m)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private var unitToggle: some View {
        HStack(spacing: 0) {
            unitOption("Kg, cm", isOn: viewModel.isMetric) { viewModel.setMetric(true) }
            unitOption("Lbs, ft", isOn: !viewModel.isMetric) { viewModel.setMetric(false) }
        }
        .padding(Layout.Spacing.xs)
        .background(Asset.Color.bgSecondary.color)
        .clipShape(Capsule())
    }

    private func unitOption(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.labelMedium)
                .foregroundStyle(isOn ? Asset.Color.white.color : Asset.Color.textSecondary.color)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(isOn ? Asset.Color.mainColor.color : .clear)
                .clipShape(Capsule())
                // `.clear` when off, which alone doesn't count as tappable content.
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func measurementRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)

            Spacer(minLength: Layout.Spacing.m)

            Text(value)
                .font(Typography.bodyMedium)
                .foregroundStyle(Asset.Color.mainColor.color)
        }
        .padding(.vertical, Layout.Spacing.s + Layout.Spacing.xs)
        .frame(height: 46)
    }
}

#Preview {
    PersonalDetailsView()
        .preview()
}

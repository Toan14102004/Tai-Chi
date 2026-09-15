//
//  ProgressActivityFormView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Figma `05 / Activity — Add Empty Form` (2168:4357), `06 / Activity — Add Filled Form`
//  (2168:4678) and `07 / Activity — Edit Existing` (2168:4738) -- one view, since the three only
//  differ in whether duration has been entered yet and whether Delete is offered.
//

import SwiftUI

struct ProgressActivityFormView: View {
    @StateObject private var viewModel: ViewModel

    init(categoryId: String,
        categoryName: String,
        iconKey: String?,
        met: Double,
        existingActivityId: String?,
        initialDurationSeconds: Int,
        initialCalories _: Double)
    {
        _viewModel = StateObject(wrappedValue: ViewModel(
            categoryId: categoryId,
            categoryName: categoryName,
            met: met,
            existingActivityId: existingActivityId,
            initialDurationSeconds: initialDurationSeconds
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: viewModel.categoryName, back: viewModel.close)

            formContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .trackScreen("progressActivityFormVC")
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            fieldSection(label: "Duration") {
                TextField("0", text: durationText)
                    .keyboardType(.numberPad)

                Spacer(minLength: Layout.Spacing.s)

                Text("min")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }

            // Read-only -- the estimate is computed from duration and the category's MET value,
            // never typed directly. Figma's own box for it (`2168:4357` -> "Estimated Calories")
            // carries no stepper or field chrome beyond this either.
            fieldSection(label: "Estimated Calories") {
                Text(viewModel.minutes > 0 ? "\(Int(viewModel.estimatedCalories))" : "0")
                    .font(valueFont)
                    .foregroundStyle(valueColor)

                Spacer(minLength: Layout.Spacing.s)

                Text("Kcal")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(Typography.captionMedium)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: Layout.Spacing.xxl)

            if viewModel.isEditing {
                Button("Delete Activity", action: viewModel.delete)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.red, lineWidth: 1))
            }

            Button(viewModel.isEditing ? "Save" : "Add", action: viewModel.save)
                .disabled(!viewModel.canSave)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(viewModel.canSave ? Asset.Color.mainColor.color : Asset.Color.textTertiary.color,
                           in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            PreloadedNativeAdsView(adKey: .discoverCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
        }
        .padding(Layout.Spacing.m)
    }

    /// A label above a white, rounded box holding a value on the left and its unit on the right --
    /// the shape both fields share in Figma (`2168:4357` -> "Frame 25", 343x54, r12).
    private func fieldSection(label: String, @ViewBuilder box: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            Text(label)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)

            HStack {
                box()
            }
            .font(valueFont)
            .foregroundStyle(valueColor)
            .padding(.horizontal, Layout.Spacing.m)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Asset.Color.white.color, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    /// Figma dims the value to secondary grey while it reads "0" (`05 / Add Empty Form`) and
    /// switches to primary once a real number is entered (`06 / Add Filled Form`).
    private var valueColor: Color {
        viewModel.minutes > 0 ? Asset.Color.textPrimary.color : Asset.Color.textSecondary.color
    }

    private var valueFont: Font { Typography.bodyMedium }

    private var durationText: Binding<String> {
        Binding(
            get: { viewModel.minutes > 0 ? "\(viewModel.minutes)" : "" },
            set: { viewModel.minutes = min(300, max(0, Int($0) ?? 0)) }
        )
    }
}

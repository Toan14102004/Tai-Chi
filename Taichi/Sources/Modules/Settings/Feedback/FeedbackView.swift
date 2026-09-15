//
//  FeedbackView.swift
//  Taichi
//
//  Created by Minh Hieu on 5/9/25.
//

import SwiftUI

struct FeedbackView: View {
    @StateObject var viewModel = FeedbackViewModel()

    var body: some View {
        BaseView {
            VStack(spacing: Layout.Spacing.l) {
                ScrollView (showsIndicators: false) {
                    VStack(spacing: Layout.Spacing.l) {
                        Text(LocalizedStringKey("Help us to make a better experience for you!"))
                            .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                            .foregroundStyle(Asset.Color.white.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Layout.Spacing.m)

                        checkboxView()
                        detailView()
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }

                submitButton()
            }
            .ignoresSafeArea(.keyboard)
        }
        .toolbar {
            BackButton(action: viewModel.goBack)

            ToolbarTitleSetting(firstPart: "Send", secondPart: "Feedback")
        }
        .trackScreen("feedbackVC")
    }
}

// MARK: View
private extension FeedbackView {
    @ViewBuilder
    func checkboxView() -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.l) {
            Text("Is our app \(AppConfiguration.appName) easy to use?")
                .font(FontFamily.Inter.regular.font(size: Layout.Text.body))
                .foregroundStyle(Asset.Color.white.color)

            Divider()
                .background(Asset.Color.gray.color.opacity(0.2))

            VStack(spacing: Layout.Spacing.m) {
                HStack(spacing: Layout.Spacing.m) {
                    RadioButton(
                        isSelected: Binding(get: {
                            viewModel.selectedAnswer == .yes
                        }, set: { value in
                            viewModel.selectedAnswer = value ? .yes : .no
                        }),
                        action: {
                            viewModel.selectAnswer(.yes)
                        }
                    )
                    
                    Text("Yes")
                        .font(FontFamily.Inter.regular.font(size: Layout.Text.body))
                        .foregroundStyle(Asset.Color.white.color)
                }

                HStack(spacing: Layout.Spacing.m) {
                    RadioButton(
                        isSelected: Binding(get: {
                            viewModel.selectedAnswer == .no
                        }, set: { value in
                            viewModel.selectedAnswer = value ? .no : .yes
                        }),
                        action: {
                            viewModel.selectAnswer(.no)
                        }
                    )
                    Text("No")
                        .font(FontFamily.Inter.regular.font(size: Layout.Text.body))
                        .foregroundStyle(Asset.Color.white.color)
                }
            }
        }
        .padding(Layout.Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                .fill(Asset.Color.colorTaichi.color)
                .overlay{
                    RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                        .stroke(Asset.Color.gray.color.opacity(0.2), lineWidth: 1)
                }
        )
        .padding(.horizontal, Layout.Spacing.m)
    }
    
    @ViewBuilder
    func detailView() -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            Text("Give us more details about your problem")
                .font(FontFamily.Inter.regular.font(size: Layout.Text.subheadline))
                .foregroundStyle(Asset.Color.white.color)

            Divider()
                .background(Asset.Color.gray.color.opacity(0.2))

            TextField(
                "",
                text: $viewModel.feedbackText,
                prompt: Text("Type here...").foregroundColor(Asset.Color.gray.color),
                axis: .vertical
            )
            .multilineTextAlignment(.leading)
            .lineLimit(10...15)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .font(FontFamily.Inter.regular.font(size: Layout.Text.body))
            .foregroundColor(Asset.Color.white.color)
        }
        .padding(Layout.Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                .fill(Asset.Color.colorTaichi.color)
                .overlay{
                    RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                        .stroke(Asset.Color.gray.color.opacity(0.2), lineWidth: 1)
                }
        )
        .padding(.horizontal, Layout.Spacing.m)
    }
    
    @ViewBuilder
    func submitButton() -> some View {
        Button(action: {
            viewModel.submitFeedback()
        }) {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }

                Text("SEND")
                    .font(FontFamily.Inter.bold.font(size: Layout.Text.headline))
                    .foregroundColor(Asset.Color.black.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.s)
            }
        }
        .buttonStyle(
            CapsuleButtonStyle(
                background: (viewModel.canSubmit && !viewModel.isSubmitting) ?
                Asset.Color.mainColor.color : Color.gray
            )
        )
        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
        .padding(.horizontal, Layout.Spacing.l)
    }
}

#Preview {
    FeedbackView()
        .preview()
}

//
//  CustomAlertView.swift
//  Taichi
//
//  Created by Toan Nguyen on 11/12/24.
//

import Foundation
import SwiftUI

struct CustomAlertView<Content: View>: View {
    var icon: Image?
    let title: LocalizedStringKey?
    var titleColor: Color = Asset.Color.white.color
    var description: LocalizedStringKey?
    var descriptionColor: Color = Asset.Color.grayText.color
    
    var background: Color = Asset.Color.bgPopup.color
    var showLine: Bool = false
    var buttonAxis: Axis = .horizontal
    
    var cancelActionTitle: LocalizedStringKey?
    var cancelActionTitleColor: Color = Asset.Color.white.color
    var cancelAction: (() -> Void)?
    
    var isPrimaryActionReady: () -> Bool = { true }
    var primaryActionTitle: LocalizedStringKey?
    var primaryActionTitleColor: Color = Asset.Color.black.color
    var primaryActionBackground: Color = Asset.Color.mainColor.color
    var primaryAction: (() -> Void)?
    var dismissAction: (() -> Void)?
    
    @ViewBuilder var customContent: () -> Content
    
    var body: some View {
        VStack(spacing: Layout.Spacing.m) {
            // Icon
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.Icon.xxl, height: Layout.Icon.xxl)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
            
            // Title
            if let title {
                Text(title)
                    .font(.system(size: Layout.Text.title3, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(titleColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Description
            if let description {
                Text(description)
                    .font(.system(size: Layout.Text.body, weight: .regular))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(descriptionColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Custom Content
            customContent()
                .padding(.vertical, Layout.Spacing.xs)
            
            // Buttons
            if buttonAxis == .horizontal {
                if showLine {
                    customDivider()
                        .frame(height: 1)
                }
                
                HStack(spacing: Layout.Spacing.m) {
                    if let cancelAction, let cancelActionTitle {
                        Button {
                            cancelAction()
                            dismissAction?()
                        } label: {
                            Text(cancelActionTitle)
                                .font(.system(size: Layout.Text.body, weight: .semibold))
                                .foregroundStyle(cancelActionTitleColor)
                                .frame(height: Layout.Button.height)
                                .frame(maxWidth: .infinity)
                                .background(Asset.Color.gray.color.opacity(0.3))
                                .cornerRadius(Layout.CornerRadius.medium)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let primaryAction, let primaryActionTitle {
                        Button {
                            if isPrimaryActionReady() {
                                primaryAction()
                                dismissAction?()
                            }
                        } label: {
                            Text(primaryActionTitle)
                                .font(.system(size: Layout.Text.body, weight: .semibold))
                                .foregroundColor(
                                    isPrimaryActionReady() ? primaryActionTitleColor : Asset.Color.grayText.color
                                )
                                .frame(height: Layout.Button.height)
                                .frame(maxWidth: .infinity)
                                .background(
                                    isPrimaryActionReady()
                                    ? primaryActionBackground : Asset.Color.gray.color.opacity(0.3)
                                )
                                .cornerRadius(Layout.CornerRadius.medium)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: Layout.Spacing.s) {
                    if let primaryAction, let primaryActionTitle {
                        Button {
                            if isPrimaryActionReady() {
                                primaryAction()
                                dismissAction?()
                            }
                        } label: {
                            Text(primaryActionTitle)
                                .font(.system(size: Layout.Text.body, weight: .semibold))
                                .foregroundColor(
                                    isPrimaryActionReady() ? primaryActionTitleColor : Asset.Color.grayText.color
                                )
                                .frame(height: Layout.Button.height)
                                .frame(maxWidth: .infinity)
                                .background(
                                    isPrimaryActionReady()
                                    ? primaryActionBackground : Asset.Color.gray.color.opacity(0.3)
                                )
                                .cornerRadius(Layout.CornerRadius.medium)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    if let cancelAction, let cancelActionTitle {
                        Button {
                            cancelAction()
                            dismissAction?()
                        } label: {
                            Text(cancelActionTitle)
                                .font(.system(size: Layout.Text.body, weight: .semibold))
                                .foregroundStyle(cancelActionTitleColor)
                                .frame(height: Layout.Button.height)
                                .frame(maxWidth: .infinity)
                                .background(Asset.Color.gray.color.opacity(0.3))
                                .cornerRadius(Layout.CornerRadius.medium)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        .padding(Layout.Spacing.l)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background(background)
        .cornerRadius(Layout.CornerRadius.xxl)
        .shadow(
            color: .black.opacity(0.3), radius: Layout.Shadow.largeRadius, x: 0,
            y: Layout.Shadow.mediumOffsetY
        )
        .padding(.horizontal, Layout.Spacing.l)
    }
    
    func customDivider() -> some View {
        Divider().overlay(Asset.Color.gray.color.opacity(0.3))
    }
}

extension CustomAlertView where Content == EmptyView {
    init(
        icon: Image? = nil,
        title: LocalizedStringKey?,
        titleColor: Color = Asset.Color.white.color,
        description: LocalizedStringKey? = nil,
        descriptionColor: Color = Asset.Color.grayText.color,
        
        background: Color = Asset.Color.bgPopup.color,
        showLine: Bool = false,
        buttonAxis: Axis = .horizontal,
        
        cancelActionTitle: LocalizedStringKey? = "Cancel",
        cancelActionTitleColor: Color = Asset.Color.white.color,
        cancelAction: (() -> Void)? = nil,
        
        isPrimaryActionReady: @escaping () -> Bool = { true },
        primaryActionTitle: LocalizedStringKey? = "OK",
        primaryActionTitleColor: Color = Asset.Color.black.color,
        primaryActionBackground: Color = Asset.Color.mainColor.color,
        primaryAction: (() -> Void)? = nil,
        dismissAction _: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.description = description
        self.descriptionColor = descriptionColor
        
        self.background = background
        self.showLine = showLine
        self.buttonAxis = buttonAxis
        
        self.cancelAction = cancelAction
        self.cancelActionTitleColor = cancelActionTitleColor
        self.cancelActionTitle = cancelActionTitle
        
        self.isPrimaryActionReady = isPrimaryActionReady
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionTitleColor = primaryActionTitleColor
        self.primaryActionBackground = primaryActionBackground
        self.primaryAction = primaryAction
        
        customContent = { EmptyView() }
    }
}

#Preview(body: {
    VStack(spacing: Layout.Spacing.xl) {
        // Alert with both buttons (vertical)
        CustomAlertView(
            icon: Image(systemName: "exclamationmark.triangle.fill"),
            title: "Delete Taichi?",
            description:
                "Are you sure you want to delete this food from your collection? This action cannot be undone.",
            cancelActionTitle: "Cancel",
            cancelAction: {},
            primaryActionTitle: "Delete",
            primaryAction: {}
        )
        
        // Alert with single button
        CustomAlertView(
            icon: Image(systemName: "checkmark.circle.fill"),
            title: "Success!",
            description: "Your food has been added to the collection.",
            primaryActionTitle: "Done",
            primaryAction: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Asset.Color.black.color)
})

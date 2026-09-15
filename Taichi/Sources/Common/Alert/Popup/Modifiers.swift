//
//  Modifiers.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

public extension EnvironmentValues {
    /// A closure that dismisses the current popup when invoked.
    ///
    /// - Returns: An optional closure that dismisses the popup, or `nil` if no dismissal action is set.
    /// - Note: Use the setter to provide a custom dismissal action for the popup.
    var popupDismiss: (() -> Void)? {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

public extension View {
    /// Presents a popup view that can be shown or dismissed based on a binding state
    /// - Parameters:
    ///   - isPresented: A binding to a boolean that determines whether the popup is visible.
    ///   - view: A `@ViewBuilder` closure that returns the content of the popup as a `View`.
    ///   - customize: A closure that allows customization of the popup's parameters, such as its appearance or
    /// behavior.
    ///
    /// - Note: The popup's lifecycle is tied to the `isPresented` binding, and the `customize` closure can be used
    ///   to adjust properties like animation, size, or positioning.
    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
    ) -> some View {
        modifier(
            FullscreenPopup<Int, PopupContent>(
                isPresented: isPresented,
                isBoolMode: true,
                params: customize(Popup<PopupContent>.PopupParameters()),
                view: view,
                itemView: nil
            )
        )
        .environment(\.popupDismiss) {
            isPresented.wrappedValue = false
        }
    }

    /// Presents a popup view tied to an optional item, displaying custom content when the item is non-nil.
    /// - Parameters:
    ///   - item: A binding to an optional item. The popup is shown when this value is non-nil and dismissed when it is
    /// `nil`.
    ///   - itemView: A `@ViewBuilder` closure that takes the unwrapped `Item` and returns the popup's content as a
    /// `View`.
    ///   - customize: A closure that takes the default `PopupParameters` and returns a modified version to customize
    ///     the popup's appearance or behavior (e.g., animation, size, or positioning).
    ///
    /// - Returns: A modified view that includes the popup functionality, conforming to the `View` protocol.
    func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
    ) -> some View {
        modifier(
            FullscreenPopup<Item, PopupContent>(
                item: item,
                isBoolMode: false,
                params: customize(Popup<PopupContent>.PopupParameters()),
                view: nil,
                itemView: itemView
            )
        )
        .environment(\.popupDismiss) {
            item.wrappedValue = nil
        }
    }

    /// Presents a fullscreen popup view when `isPresented` is `true`.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the popup is displayed.
    ///   - view: A closure that returns the content of the popup.
    /// - Returns: A modified view that presents a fullscreen popup when `isPresented` is `true`.
    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent
    ) -> some View {
        modifier(
            FullscreenPopup<Int, PopupContent>(
                isPresented: isPresented,
                isBoolMode: true,
                params: Popup<PopupContent>.PopupParameters(),
                view: view,
                itemView: nil
            )
        )
        .environment(\.popupDismiss) {
            isPresented.wrappedValue = false
        }
    }

    /// Presents a fullscreen popup view when `item` is not `nil`.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional item. When `item` is non-nil, the popup is displayed.
    ///   - itemView: A closure that returns the content of the popup, using the provided `Item`.
    /// - Returns: A modified view that presents a fullscreen popup when `item` is set.
    func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent
    ) -> some View {
        modifier(
            FullscreenPopup<Item, PopupContent>(
                item: item,
                isBoolMode: false,
                params: Popup<PopupContent>.PopupParameters(),
                view: nil,
                itemView: itemView
            )
        )
        .environment(\.popupDismiss) {
            item.wrappedValue = nil
        }
    }
}

#if os(iOS)

    extension View {
        func onOrientationChange(isLandscape: Binding<Bool>, onOrientationChange: @escaping () -> Void) -> some View {
            modifier(OrientationChangeModifier(isLandscape: isLandscape, onOrientationChange: onOrientationChange))
        }
    }

    struct OrientationChangeModifier: ViewModifier {
        @Binding var isLandscape: Bool
        let onOrientationChange: () -> Void

        func body(content: Content) -> some View {
            content
                .onAppear {
                    #if os(iOS)
                        NotificationCenter.default.addObserver(
                            forName: UIDevice.orientationDidChangeNotification,
                            object: nil,
                            queue: .main
                        ) { _ in
                            updateOrientation()
                        }
                        updateOrientation()
                    #endif
                }
                .onDisappear {
                    #if os(iOS)
                        NotificationCenter.default.removeObserver(
                            self,
                            name: UIDevice.orientationDidChangeNotification,
                            object: nil
                        )
                    #endif
                }
                .onChange(of: isLandscape) { _ in
                    onOrientationChange()
                }
        }

        #if os(iOS)
            private func updateOrientation() {
                DispatchQueue.main.async {
                    let newIsLandscape = UIDevice.current.orientation.isLandscape
                    if newIsLandscape != isLandscape {
                        isLandscape = newIsLandscape
                        onOrientationChange()
                    }
                }
            }
        #endif
    }

#endif

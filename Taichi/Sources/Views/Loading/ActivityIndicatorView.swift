//
//  ActivityIndicatorView.swift
//  Taichi
//
//  Created by Toan Nguyen on 12/9/25.
//

import Foundation
import SwiftUI

public struct ActivityIndicatorView: View {
    public enum IndicatorType {
        case `default`(count: Int = 8)
        case arcs(count: Int = 3, lineWidth: CGFloat = 2)
        case rotatingDots(count: Int = 5)
        case flickeringDots(count: Int = 8)
        case scalingDots(count: Int = 3, inset: Int = 2)
        case opacityDots(count: Int = 3, inset: Int = 4)
        case equalizer(count: Int = 5)
        case growingArc(Color = .black, lineWidth: CGFloat = 4)
        case growingCircle
        case gradient(_ colors: [Color], CGLineCap = .butt, lineWidth: CGFloat = 4)
    }

    @Binding var isVisible: Bool
    var type: IndicatorType

    public init(isVisible: Binding<Bool>, type: IndicatorType) {
        _isVisible = isVisible
        self.type = type
    }

    public var body: some View {
        if isVisible {
            indicator
        } else {
            EmptyView()
        }
    }

    // MARK: - Private

    private var indicator: some View {
        ZStack {
            switch type {
            case let .default(count):
                DefaultIndicatorView(count: count)
            case let .arcs(count, lineWidth):
                ArcsIndicatorView(count: count, lineWidth: lineWidth)
            case let .rotatingDots(count):
                RotatingDotsIndicatorView(count: count)
            case let .flickeringDots(count):
                FlickeringDotsIndicatorView(count: count)
            case let .scalingDots(count, inset):
                ScalingDotsIndicatorView(count: count, inset: inset)
            case let .opacityDots(count, inset):
                OpacityDotsIndicatorView(count: count, inset: inset)
            case let .equalizer(count):
                EqualizerIndicatorView(count: count)
            case let .growingArc(color, lineWidth):
                GrowingArcIndicatorView(color: color, lineWidth: lineWidth)
            case .growingCircle:
                GrowingCircleIndicatorView()
            case let .gradient(colors, lineCap, lineWidth):
                GradientIndicatorView(colors: colors, lineCap: lineCap, lineWidth: lineWidth)
            }
        }
    }
}

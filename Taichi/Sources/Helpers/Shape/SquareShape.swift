//
//  SquareShape.swift
//  Taichi
//
//  Created by Toan Nguyen on 19/1/26.
//

import Foundation
import SwiftUI

struct SquareShape: Shape {
    var innerRadiusRatio: CGFloat = 0.0
    var cornerRadius: CGFloat = 0.0
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(innerRadiusRatio, cornerRadius) }
        set {
            innerRadiusRatio = newValue.first
            cornerRadius = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let size = min(rect.width, rect.height)
        let radius = size / 2
        let innerRadius = radius * innerRadiusRatio
        
        let outerRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: size,
            height: size
        )
        
        path.addRoundedRect(in: outerRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        if innerRadiusRatio > 0 {
            let innerSize = innerRadius * 2
            let innerRect = CGRect(
                x: center.x - innerRadius,
                y: center.y - innerRadius,
                width: innerSize,
                height: innerSize
            )
            
            let thickness = radius - innerRadius
            let innerCornerRadius = max(0, cornerRadius - thickness)
            
            path.move(to: CGPoint(x: innerRect.minX, y: innerRect.midY))
            
            path.addArc(tangent1End: CGPoint(x: innerRect.minX, y: innerRect.maxY),
                        tangent2End: CGPoint(x: innerRect.maxX, y: innerRect.maxY),
                        radius: innerCornerRadius)
            
            // Góc dưới phải (Bottom-Right)
            path.addArc(tangent1End: CGPoint(x: innerRect.maxX, y: innerRect.maxY),
                        tangent2End: CGPoint(x: innerRect.maxX, y: innerRect.minY),
                        radius: innerCornerRadius)
            
            path.addArc(tangent1End: CGPoint(x: innerRect.maxX, y: innerRect.minY),
                        tangent2End: CGPoint(x: innerRect.minX, y: innerRect.minY),
                        radius: innerCornerRadius)
            
            path.addArc(tangent1End: CGPoint(x: innerRect.minX, y: innerRect.minY),
                        tangent2End: CGPoint(x: innerRect.minX, y: innerRect.maxY),
                        radius: innerCornerRadius)
            
            path.closeSubpath()
        }
        
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        SquareShape(cornerRadius: 20)
            .fill(Color.purple)
            .frame(width: 150, height: 150)
            .overlay(Text("Solid").foregroundColor(.white))
        
        HStack {
            SquareShape(innerRadiusRatio: 0.5, cornerRadius: 20)
                .fill(Color.blue)
                .frame(width: 100, height: 100)
            
            SquareShape(innerRadiusRatio: 0.85, cornerRadius: 15)
                .fill(Color.green)
                .frame(width: 100, height: 100)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

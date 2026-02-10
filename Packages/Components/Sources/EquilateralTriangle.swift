// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct EquilateralTriangle: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }

    public static func image(pointingUp: Bool, size: CGFloat = 10) -> Image {
        let height = size * sin(.pi / 3)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: height))
        let uiImage = renderer.image { _ in
            let bezierPath = UIBezierPath()
            if pointingUp {
                bezierPath.move(to: CGPoint(x: size / 2, y: 0))
                bezierPath.addLine(to: CGPoint(x: size, y: height))
                bezierPath.addLine(to: CGPoint(x: 0, y: height))
            } else {
                bezierPath.move(to: CGPoint(x: size / 2, y: height))
                bezierPath.addLine(to: CGPoint(x: size, y: 0))
                bezierPath.addLine(to: CGPoint(x: 0, y: 0))
            }
            bezierPath.close()
            UIColor.black.setFill()
            bezierPath.fill()
        }.withRenderingMode(.alwaysTemplate)
        return Image(uiImage: uiImage)
    }
}

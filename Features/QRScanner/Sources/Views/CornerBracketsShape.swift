// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CornerBracketsShape: Shape {
    let cornerRadius: CGFloat
    let cornerLength: CGFloat

    let boxSize: CGFloat
    let containerSize: CGSize

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let left = (containerSize.width  - boxSize) / 2
        let right = left + boxSize
        let top = (containerSize.height - boxSize) / 2
        let bottom = top + boxSize

        // top left corner
        path.move(to: CGPoint(x: left, y: top + cornerRadius))
        path.addArc(
            center: CGPoint(x: left + cornerRadius, y: top + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle:   .degrees(270),
            clockwise:  false
        )
        path.move(to: CGPoint(x: left + cornerRadius, y: top))
        path.addLine(to: CGPoint(x: left + cornerRadius + cornerLength, y: top))
        path.move(to: CGPoint(x: left, y: top + cornerRadius))
        path.addLine(to: CGPoint(x: left, y: top + cornerRadius + cornerLength))

        // top right corner
        path.move(to: CGPoint(x: right, y: top + cornerRadius))
        path.addArc(
            center: CGPoint(x: right - cornerRadius, y: top + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(360),
            endAngle:   .degrees(270),
            clockwise:  true
        )
        path.move(to: CGPoint(x: right - cornerRadius - cornerLength, y: top))
        path.addLine(to: CGPoint(x: right - cornerRadius, y: top))
        path.move(to: CGPoint(x: right, y: top + cornerRadius))
        path.addLine(to: CGPoint(x: right, y: top + cornerRadius + cornerLength))

        // bottom left corner
        path.move(to: CGPoint(x: left, y: bottom - cornerRadius))
        path.addArc(
            center: CGPoint(x: left + cornerRadius, y: bottom - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle:   .degrees(90),
            clockwise:  true
        )
        path.move(to: CGPoint(x: left + cornerRadius, y: bottom))
        path.addLine(to: CGPoint(x: left + cornerRadius + cornerLength, y: bottom))
        path.move(to: CGPoint(x: left, y: bottom - cornerRadius))
        path.addLine(to: CGPoint(x: left, y: bottom - cornerRadius - cornerLength))

        // bottom right corner
        path.move(to: CGPoint(x: right, y: bottom - cornerRadius))
        path.addArc(
            center: CGPoint(x: right - cornerRadius, y: bottom - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle:   .degrees(90),
            clockwise:  false
        )
        path.move(to: CGPoint(x: right - cornerRadius - cornerLength, y: bottom))
        path.addLine(to: CGPoint(x: right - cornerRadius, y: bottom))
        path.move(to: CGPoint(x: right, y: bottom - cornerRadius))
        path.addLine(to: CGPoint(x: right, y: bottom - cornerRadius - cornerLength))

        return path
    }
}

#Preview {
    GeometryReader { proxy in
        CornerBracketsShape(
            cornerRadius: 25,
            cornerLength: 25,
            boxSize: 200,
            containerSize: proxy.size
        )
        .background(.red)
    }
}

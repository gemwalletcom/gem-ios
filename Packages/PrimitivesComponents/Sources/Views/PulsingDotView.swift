// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct PulsingDotView: View {
    private let color: Color
    private let dotSize: CGFloat
    private let isAnimated: Bool

    @State private var pulsePhase: CGFloat = 0

    init(
        color: Color,
        dotSize: CGFloat = 8,
        isAnimated: Bool = true
    ) {
        self.color = color
        self.dotSize = dotSize
        self.isAnimated = isAnimated
    }

    var body: some View {
        ZStack {
            pulseRing(scale: 3.0, delay: 0)
            pulseRing(scale: 2.5, delay: 0.4)
            centerDot
        }
        .onAppear {
            guard isAnimated else { return }
            startAnimation()
        }
    }
}

// MARK: - Components

extension PulsingDotView {
    private var centerDot: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Colors.white, color],
                    center: .center,
                    startRadius: 0,
                    endRadius: dotSize / 2
                )
            )
            .frame(width: dotSize, height: dotSize)
            .shadow(color: color.opacity(0.8), radius: 6)
            .shadow(color: color.opacity(0.4), radius: 12)
    }

    private func pulseRing(scale: CGFloat, delay: Double) -> some View {
        PulseRingView(
            color: color,
            size: dotSize,
            maxScale: scale,
            delay: delay,
            isAnimated: isAnimated
        )
    }
}

// MARK: - Actions

extension PulsingDotView {
    private func startAnimation() {
        withAnimation(.linear(duration: 0.01)) {
            pulsePhase = 1
        }
    }
}

// MARK: - PulseRingView

private struct PulseRingView: View {
    let color: Color
    let size: CGFloat
    let maxScale: CGFloat
    let delay: Double
    let isAnimated: Bool

    @State private var isExpanded = false

    private let animationDuration: Double = 1.8

    var body: some View {
        Circle()
            .stroke(color.opacity(0.4), lineWidth: 1.5)
            .frame(width: size, height: size)
            .scaleEffect(isExpanded ? maxScale : 1.0)
            .opacity(isExpanded ? 0 : 0.8)
            .onAppear {
                guard isAnimated else { return }
                withAnimation(
                    .easeOut(duration: animationDuration)
                    .delay(delay)
                    .repeatForever(autoreverses: false)
                ) {
                    isExpanded = true
                }
            }
    }
}

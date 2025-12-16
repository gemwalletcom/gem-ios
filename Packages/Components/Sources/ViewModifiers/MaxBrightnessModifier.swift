// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import UIKit

public extension View {
    func maxBrightness() -> some View {
        modifier(MaxBrightnessModifier())
    }
}

private struct MaxBrightnessModifier: ViewModifier {
    @State private var brightness: CGFloat = UIScreen.main.brightness

    func body(content: Content) -> some View {
        content
            .task {
                brightness = UIScreen.main.brightness
                await setBrightness(1.0)
            }
            .onDisappear {
                Task { await setBrightness(brightness) }
            }
    }

    private func setBrightness(_ target: CGFloat) async {
        let start = UIScreen.main.brightness
        let steps = 20
        for step in 1...steps {
            try? await Task.sleep(nanoseconds: 15_000_000)
            UIScreen.main.brightness = start + (target - start) * CGFloat(step) / CGFloat(steps)
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    public static var scale: Self {
        ScaleButtonStyle()
    }
}

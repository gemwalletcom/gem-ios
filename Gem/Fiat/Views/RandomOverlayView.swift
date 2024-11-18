// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct RandomOverlayView: View {
    private let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#2A32FF"),
                        Color(hex: "#6CB8FF"),
                        Color(hex: "#F213F6"),
                        Color(hex: "FFF963")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
    }
}

#Preview {
    RandomOverlayView()
}

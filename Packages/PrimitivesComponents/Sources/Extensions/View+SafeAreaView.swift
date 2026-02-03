// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

public extension View {
    @ViewBuilder
    func safeAreaView<Content: View>(
        edge: VerticalEdge = .bottom,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            safeAreaBar(edge: edge) {
                content()
            }
        } else {
            safeAreaInset(edge: edge) {
                content()
            }
        }
    }
}

public extension View {
    @ViewBuilder
    func safeAreaButton(
        isVisible: Bool = true,
        edge: VerticalEdge = .bottom,
        bottomPadding: CGFloat = .scene.bottom,
        maxWidth: CGFloat = .scene.button.maxWidth,
        @ViewBuilder button: () -> StateButton
    ) -> some View {
        if isVisible {
            safeAreaView(edge: edge) {
                button()
                    .frame(maxWidth: maxWidth)
                    .padding(.bottom, bottomPadding)
            }
        } else {
            self
        }
    }
}

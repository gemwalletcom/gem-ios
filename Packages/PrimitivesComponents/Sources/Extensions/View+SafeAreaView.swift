// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

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

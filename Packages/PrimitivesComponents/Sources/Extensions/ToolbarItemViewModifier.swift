// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct ToolbarItemViewModifier<V: View>: ViewModifier {
    let placement: ToolbarItemPlacement
    let toolbarContent: () -> V

    init(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.placement = placement
        self.toolbarContent = content
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemView(placement: placement, content: toolbarContent)
            }
    }
}

public extension View {
    func toolbarItemView<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ToolbarItemViewModifier(placement: placement, content: content))
    }
}

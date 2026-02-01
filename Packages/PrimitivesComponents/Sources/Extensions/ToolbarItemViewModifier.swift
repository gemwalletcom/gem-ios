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

extension View {
    func toolbarItemView<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ToolbarItemViewModifier(placement: placement, content: content))
    }
}

public extension View {
    func toolbarContent(@ToolbarContentBuilder _ content: @escaping () -> some ToolbarContent) -> some View {
        toolbar(content: content)
    }
}

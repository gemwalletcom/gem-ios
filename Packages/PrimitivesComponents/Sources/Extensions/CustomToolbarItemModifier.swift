// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CustomToolbarItemModifier<V: View>: ViewModifier {
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
                CustomToolbarItem(placement: placement, content: toolbarContent)
            }
    }
}

public extension View {
    func customToolbarItem<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(CustomToolbarItemModifier(placement: placement, content: content))
    }
}

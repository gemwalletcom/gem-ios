// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct ToolbarDismissItemModifier: ViewModifier {
    let title: ToolbarDismissItem.Title
    let placement: ToolbarItemPlacement
    
    public init(
        title: ToolbarDismissItem.Title,
        placement: ToolbarItemPlacement
    ) {
        self.title = title
        self.placement = placement
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarDismissItem(
                    title: title,
                    placement: placement
                )
            }
    }
}

public extension View {
    func toolbarDismissItem(
        title: ToolbarDismissItem.Title,
        placement: ToolbarItemPlacement
    ) -> some View {
        modifier(ToolbarDismissItemModifier(title: title, placement: placement))
    }
}

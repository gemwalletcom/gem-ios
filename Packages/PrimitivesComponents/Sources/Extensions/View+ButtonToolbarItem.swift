// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DismissToolbarItemModifier: ViewModifier {
    let title: DismissToolbarItem.Title
    let placement: ToolbarItemPlacement
    
    public init(
        title: DismissToolbarItem.Title,
        placement: ToolbarItemPlacement
    ) {
        self.title = title
        self.placement = placement
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                DismissToolbarItem(
                    title: title,
                    placement: placement
                )
            }
    }
}

public extension View {
    func dismissToolbarItem(
        title: DismissToolbarItem.Title,
        placement: ToolbarItemPlacement
    ) -> some View {
        modifier(DismissToolbarItemModifier(title: title, placement: placement))
    }
}

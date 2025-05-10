// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ToolbarItemView<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let content: () -> Content

    public init(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.placement = placement
        self.content = content
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: placement, content: content)
    }
}

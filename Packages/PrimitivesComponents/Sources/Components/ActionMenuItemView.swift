// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct ActionMenuItemView: View {
    private let item: ActionMenuItemType

    public init(item: ActionMenuItemType) {
        self.item = item
    }

    public var body: some View {
        switch item {
        case let .button(title, systemImage, role, action):
            ContextMenuItem(
                title: title,
                systemImage: systemImage,
                role: role,
                action: { action?() }
            )
        }
    }
}

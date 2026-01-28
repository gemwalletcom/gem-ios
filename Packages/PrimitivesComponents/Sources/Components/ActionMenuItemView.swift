// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct ActionMenuItemView: View {
    private let item: ActionMenuItemType

    init(item: ActionMenuItemType) {
        self.item = item
    }

    var body: some View {
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

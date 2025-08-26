// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension View {
    func contextMenu<MenuItems: View>(
        _ items: [ContextMenuItemType],
        @ViewBuilder menuItemsBuilder: @escaping ([ContextMenuItemType]) -> MenuItems
    ) -> some View {
        self.contextMenu {
            menuItemsBuilder(items)
        }
    }

    func contextMenu<MenuItems: View>(
        _ item: ContextMenuItemType,
        @ViewBuilder menuItemsBuilder: @escaping ([ContextMenuItemType]) -> MenuItems
    ) -> some View {
        contextMenu([item], menuItemsBuilder: menuItemsBuilder)
    }

    func contextMenu<MenuItems: View>(
        configuration: ContextMenuConfiguration?,
        @ViewBuilder menuItemsBuilder: @escaping ([ContextMenuItemType]) -> MenuItems
    ) -> some View {
        Group {
            if let configuration = configuration {
                self.contextMenu(configuration.items, menuItemsBuilder: menuItemsBuilder)
            } else {
                self
              }
        }
    }
}
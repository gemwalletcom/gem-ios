// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ContextMenuConfiguration {
    public let items: [ContextMenuItemType]
    
    public init(items: [ContextMenuItemType]) {
        self.items = items
    }
    
    public init(item: ContextMenuItemType) {
        self.items = [item]
    }
}

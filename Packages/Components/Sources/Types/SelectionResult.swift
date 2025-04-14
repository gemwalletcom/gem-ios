// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SelectionResult<Item> {
    public let items: [Item]
    public let isConfirmed: Bool
    
    public init(items: [Item], isConfirmed: Bool) {
        self.items = items
        self.isConfirmed = isConfirmed
    }
}

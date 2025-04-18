// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Wallet {
    static func mock(
        id: String = UUID().uuidString,
        name: String = "Wallet \(UUID().uuidString)",
        accounts: [Account] = [],
        index: Int = 0
    ) -> Wallet {
        Wallet(
            id: id,
            name: name,
            index: Int32(index),
            type: .multicoin,
            accounts: accounts,
            order: 0,
            isPinned: false,
            imageUrl: nil
        )
    }
}

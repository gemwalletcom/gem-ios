// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Wallet {
    static func mock(
        accounts: [Account] = []
    ) -> Wallet {
        Wallet(
            id: "",
            name: "",
            index: 0,
            type: .multicoin,
            accounts: accounts,
            order: 0,
            isPinned: false
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Wallet {
    static func mock(
        id: String = "",
        externalId: String? = nil,
        name: String = "",
        type: WalletType = .multicoin,
        accounts: [Account] = [],
        index: Int = 0,
        order: Int = 0,
        source: WalletSource = .create
    ) -> Wallet {
        Wallet(
            id: id,
            externalId: externalId,
            name: name,
            index: index.asInt32,
            type: type,
            accounts: accounts,
            order: order.asInt32,
            isPinned: false,
            imageUrl: nil,
            source: source
        )
    }
}

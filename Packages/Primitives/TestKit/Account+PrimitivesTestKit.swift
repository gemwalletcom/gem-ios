// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Account {
    static func mock(
        chain: Chain = .mock(),
        address: String = .empty
    ) -> Account {
        Account(
            chain: chain,
            address: address,
            derivationPath: .empty,
            extendedPublicKey: .empty
        )
    }
}

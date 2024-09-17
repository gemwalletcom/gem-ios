// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Account {
    static func mock(
        chain: Chain = .mock()
    ) -> Account {
        Account(
            chain: chain,
            address: .empty,
            derivationPath: .empty,
            extendedPublicKey: .empty
        )
    }
}

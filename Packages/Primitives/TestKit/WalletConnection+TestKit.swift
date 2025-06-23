// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension WalletConnection {
    static func mock() -> WalletConnection {
        WalletConnection(
            session: .mock(),
            wallet: .mock()
        )
    }
}

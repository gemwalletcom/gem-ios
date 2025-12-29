// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension WalletConnection {
    static func mock(
        session: WalletConnectionSession = .mock(),
        wallet: Wallet = .mock()
    ) -> WalletConnection {
        WalletConnection(
            session: session,
            wallet: wallet
        )
    }
}

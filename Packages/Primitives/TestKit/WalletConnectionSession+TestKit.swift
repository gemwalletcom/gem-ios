// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public extension WalletConnectionSession {
    static func mock() -> WalletConnectionSession {
        WalletConnectionSession(
            id: .empty,
            sessionId: .empty,
            state: .active,
            chains: [.ethereum],
            createdAt: .now,
            expireAt: .distantFuture,
            metadata: WalletConnectionSessionAppMetadata(
                name: .empty,
                description: .empty,
                url: .empty,
                icon: .empty,
                redirectNative: .empty,
                redirectUniversal: .empty
            )
        )
    }
}

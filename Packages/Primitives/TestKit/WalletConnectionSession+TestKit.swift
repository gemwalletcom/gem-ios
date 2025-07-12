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

public extension WalletConnectionSessionAppMetadata {
    static func mock(
        name: String = "",
        description: String = "",
        url: String = "",
        icon: String = "",
        redirectNative: String? = nil,
        redirectUniversal: String? = nil
    ) -> WalletConnectionSessionAppMetadata {
        WalletConnectionSessionAppMetadata(
            name: name,
            description: description,
            url: url,
            icon: icon,
            redirectNative: redirectNative,
            redirectUniversal: redirectUniversal
        )
    }
}

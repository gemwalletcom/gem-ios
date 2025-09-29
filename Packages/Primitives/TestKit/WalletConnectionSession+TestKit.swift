// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension WalletConnectionSession {
    static func mock(
        id: String = .empty,
        sessionId: String = .empty,
        state: WalletConnectionState = .active,
        chains: [Chain] = [.ethereum],
        createdAt: Date = .now,
        expireAt: Date = .distantFuture,
        metadata: WalletConnectionSessionAppMetadata = .mock()
    ) -> WalletConnectionSession {
        WalletConnectionSession(
            id: id,
            sessionId: sessionId,
            state: state,
            chains: chains,
            createdAt: createdAt,
            expireAt: expireAt,
            metadata: metadata
        )
    }
}

public extension WalletConnectionSessionAppMetadata {
    static func mock(
        name: String = "",
        description: String = "",
        url: String = "",
        icon: String = ""
    ) -> WalletConnectionSessionAppMetadata {
        WalletConnectionSessionAppMetadata(
            name: name,
            description: description,
            url: url,
            icon: icon
        )
    }
}

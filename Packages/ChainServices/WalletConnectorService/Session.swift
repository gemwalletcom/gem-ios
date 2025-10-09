// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import ReownWalletKit

extension Session {
    var asSession: Primitives.WalletConnectionSession {
        WalletConnectionSession(
            id: topic,
            sessionId: topic,
            state: .active,
            chains: [],
            createdAt: .now,
            expireAt: expiryDate,
            metadata: peer.metadata
        )
    }
}

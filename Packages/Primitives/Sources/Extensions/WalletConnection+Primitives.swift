// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletConnection: Identifiable {
    public var id: String { session.id }
}
extension WalletConnectionSession: Identifiable {}

extension WalletConnectionSession {
    public static func started(id: String, chains: [Chain]) -> WalletConnectionSession {
        return WalletConnectionSession(
            id: id,
            sessionId: .empty,
            state: .started,
            chains: [],
            createdAt: .now,
            expireAt: .now,
            metadata: WalletConnectionSessionAppMetadata(
                name: .empty,
                description: .empty,
                url: .empty,
                icon: .empty,
                redirectNative: .none,
                redirectUniversal: .none
            )
        )
    }
}

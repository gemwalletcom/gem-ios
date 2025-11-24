// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct RecentActivityService: Sendable {
    private let store: RecentActivityStore

    public init(store: RecentActivityStore) {
        self.store = store
    }

    public func track(type: RecentActivityType, assetId: AssetId, walletId: WalletId) throws {
        try store.add(assetId: assetId, walletId: walletId, type: type)
    }
}

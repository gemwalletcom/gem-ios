// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct ActivityService: Sendable {
    private let store: RecentActivityStore

    public init(store: RecentActivityStore) {
        self.store = store
    }

    public func updateRecent(data: RecentActivityData, walletId: WalletId) throws {
        try store.add(assetId: data.assetId, toAssetId: data.toAssetId, walletId: walletId, type: data.type)
    }

    public func clearRecent(walletId: WalletId, types: [RecentActivityType]) throws {
        try store.clear(walletId: walletId, types: types)
    }
}

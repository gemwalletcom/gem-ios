// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct ActivityService: Sendable {
    private let store: RecentActivityStore

    public init(store: RecentActivityStore) {
        self.store = store
    }

    public func updateRecent(type: RecentActivityType, assetId: AssetId, walletId: WalletId) throws {
        try store.add(assetId: assetId, toAssetId: .none, walletId: walletId, type: type)
    }
}

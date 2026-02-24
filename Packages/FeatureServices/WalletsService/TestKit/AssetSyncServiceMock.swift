// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletsService

public struct AssetSyncServiceMock: AssetSyncServiceable {
    public init() {}

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {}
    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {}
    public func addPrices(assetIds: [AssetId]) async throws {}
}

public extension AssetSyncServiceable where Self == AssetSyncServiceMock {
    static func mock() -> AssetSyncServiceMock {
        AssetSyncServiceMock()
    }
}

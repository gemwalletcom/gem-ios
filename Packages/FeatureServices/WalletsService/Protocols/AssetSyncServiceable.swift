// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol AssetSyncServiceable: Sendable {
    func fetch(walletId: WalletId, assetIds: [AssetId]) async throws
    func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws
    func addPrices(assetIds: [AssetId]) async throws
}

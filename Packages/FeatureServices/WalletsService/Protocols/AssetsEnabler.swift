// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol AssetsEnabler: Sendable {
    func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool, shouldRefresh: Bool) async throws
    func enableAssetId(walletId: WalletId, assetId: AssetId) async throws
}

public extension AssetsEnabler {
    func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async throws {
        try await enableAssets(walletId: walletId, assetIds: assetIds, enabled: enabled, shouldRefresh: true)
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletsService

public struct AssetsEnablerMock: AssetsEnabler {
    public init() {}

    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async throws {}
    public func enableAssetId(walletId: WalletId, assetId: AssetId) async throws {}
}

public extension AssetsEnabler where Self == AssetsEnablerMock {
    static func mock() -> AssetsEnablerMock {
        AssetsEnablerMock()
    }
}

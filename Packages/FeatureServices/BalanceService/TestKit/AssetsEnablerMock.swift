// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

public struct AssetsEnablerMock: AssetsEnabler {
    public init() {}

    public func enableAssets(wallet: Wallet, assetIds: [AssetId], enabled: Bool) async throws {}
    public func enableAssetId(wallet: Wallet, assetId: AssetId) async throws {}
}

public extension AssetsEnabler where Self == AssetsEnablerMock {
    static func mock() -> AssetsEnablerMock {
        AssetsEnablerMock()
    }
}

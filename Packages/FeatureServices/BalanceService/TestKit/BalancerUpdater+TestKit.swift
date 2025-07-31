// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import Primitives

public struct BalancerUpdaterMock: BalancerUpdater {
    public init() {}
    public func updateBalance(walletId: String, asset: AssetId, address: String) async throws -> [AssetBalanceChange] {
        []
    }
    public func updateBalance(for wallet: Wallet, assetIds: [AssetId]) async {

    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletsService

public struct BalanceUpdaterMock: BalanceUpdater {
    public init() {}

    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {}
    public func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {}
}

public extension BalanceUpdater where Self == BalanceUpdaterMock {
    static func mock() -> BalanceUpdaterMock {
        BalanceUpdaterMock()
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import Primitives

public struct EarnBalanceUpdaterMock: EarnBalanceUpdatable {
    public init() {}
    public func updateEarnBalance(walletId: WalletId, chain: Chain, address: String) async -> [AssetBalanceChange] { [] }
}

public extension EarnBalanceUpdatable where Self == EarnBalanceUpdaterMock {
    static func mock() -> EarnBalanceUpdaterMock {
        EarnBalanceUpdaterMock()
    }
}

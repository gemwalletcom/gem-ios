// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import EarnService

public final class MockEarnBalanceService: EarnBalanceServiceable, @unchecked Sendable {
    public init() {}

    public func updatePositions(walletId: WalletId, assetId: AssetId, address: String) async {}
}

extension MockEarnBalanceService {
    public static func mock() -> MockEarnBalanceService {
        MockEarnBalanceService()
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import StoreTestKit
import ChainServiceTestKit
import Store
import ChainService

public extension BalanceService {
    static func mock(
        balanceStore: BalanceStore = .mock(),
        assertStore: AssetStore = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock()
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            assertStore: assertStore,
            chainServiceFactory: chainServiceFactory
        )
    }
}

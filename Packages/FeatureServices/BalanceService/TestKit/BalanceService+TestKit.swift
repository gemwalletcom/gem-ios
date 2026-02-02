// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import StoreTestKit
import ChainServiceTestKit
import Store
import ChainService
import AssetsService
import AssetsServiceTestKit
import YieldService
import YieldServiceTestKit

public extension BalanceService {
    static func mock(
        balanceStore: BalanceStore = .mock(),
        assetsService: AssetsService = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock(),
        yieldService: any YieldServiceType = MockYieldService()
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            assetsService: assetsService,
            chainServiceFactory: chainServiceFactory,
            yieldService: yieldService
        )
    }
}

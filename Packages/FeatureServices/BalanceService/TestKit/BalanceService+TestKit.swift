// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import StoreTestKit
import ChainServiceTestKit
import Store
import ChainService
import AssetsService
import AssetsServiceTestKit
import EarnService
import EarnServiceTestKit

public extension BalanceService {
    static func mock(
        balanceStore: BalanceStore = .mock(),
        earnStore: EarnStore = .mock(),
        assetsService: AssetsService = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock(),
        earnService: any EarnServiceType = MockEarnService()
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            earnStore: earnStore,
            assetsService: assetsService,
            chainServiceFactory: chainServiceFactory,
            earnService: earnService
        )
    }
}

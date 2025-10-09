// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BalanceService
import StoreTestKit
import ChainServiceTestKit
import Store
import ChainService
import AssetsService
import AssetsServiceTestKit

public extension BalanceService {
    static func mock(
        balanceStore: BalanceStore = .mock(),
        assetsService: AssetsService = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock()
    ) -> BalanceService {
        BalanceService(
            balanceStore: balanceStore,
            assetsService: assetsService,
            chainServiceFactory: chainServiceFactory
        )
    }
}

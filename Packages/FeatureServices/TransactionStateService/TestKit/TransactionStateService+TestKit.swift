// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionStateService
import Store
import StakeService
import EarnService
import NFTService
import ChainService
import BalanceService
import StoreTestKit
import StakeServiceTestKit
import EarnServiceTestKit
import NFTServiceTestKit
import ChainServiceTestKit
import BalanceServiceTestKit

public extension TransactionStateService {
    static func mock(
        transactionStore: TransactionStore = .mock(),
        stakeService: StakeService = .mock(),
        earnService: any EarnServiceable = MockEarnService(),
        nftService: NFTService = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock()
    ) -> TransactionStateService {
        TransactionStateService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            earnService: earnService,
            nftService: nftService,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: BalancerUpdaterMock()
        )
    }
}

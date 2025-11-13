// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionService
import Store
import StakeService
import NFTService
import ChainService
import BalanceService
import StoreTestKit
import StakeServiceTestKit
import NFTServiceTestKit
import ChainServiceTestKit
import BalanceServiceTestKit

public extension TransactionService {
    static func mock(
        transactionStore: TransactionStore = .mock(),
        stakeService: StakeService = .mock(),
        nftService: NFTService = .mock(),
        chainServiceFactory: ChainServiceFactory = .mock()
    ) -> TransactionService {
        TransactionService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            nftService: nftService,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: BalancerUpdaterMock()
        )
    }
}

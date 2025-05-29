// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionService
import StoreTestKit
import StakeServiceTestKit
import NFTServiceTestKit
import ChainServiceTestKit
import BalanceServiceTestKit

public extension TransactionService {
    static func mock() -> TransactionService {
        TransactionService(
            transactionStore: .mock(),
            stakeService: .mock(),
            nftService: .mock(),
            chainServiceFactory: .mock(),
            balanceUpdater: BalancerUpdaterMock()
        )
    }
}

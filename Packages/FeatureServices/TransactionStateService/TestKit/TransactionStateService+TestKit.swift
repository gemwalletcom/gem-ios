// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import TransactionStateService
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
import SwapServiceTestKit

public extension TransactionStateService {
    static func mock(
        transactionStore: TransactionStore = .mock(),
        swapper: any GemSwapperProtocol = GemSwapperMock(),
        stakeService: StakeService = .mock(),
        nftService: NFTService = .mock(),
        chainServiceFactory: any ChainServiceFactorable = ChainServiceFactoryMock()
    ) -> TransactionStateService {
        TransactionStateService(
            transactionStore: transactionStore,
            swapper: swapper,
            stakeService: stakeService,
            nftService: nftService,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: BalancerUpdaterMock()
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import StakeService
import BalanceService
import NFTService

public struct TransactionService: Sendable {
    private let transactionStore: TransactionStore
    private let poller: TransactionPoller

    public init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.poller = TransactionPoller(
            transactionUpdater: TransactionUpdater(
                transactionStore: transactionStore,
                chainServiceFactory: chainServiceFactory,
                balanceUpdater: balanceUpdater,
                stakeService: stakeService,
                nftService: nftService
            )
        )
    }

    public func setup() {
        Task {
            try await poller.start(
                transactions: try transactionStore.getTransactions(state: .pending)
            )
        }
    }

    public func addTransactions(walletId: String, transactions: [Transaction]) throws {
        try transactionStore.addTransactions(walletId: walletId, transactions: transactions)
        Task {
            try await poller.addToPoll(
                transactions: transactions.filter({ $0.state == .pending })
            )
        }
    }
}

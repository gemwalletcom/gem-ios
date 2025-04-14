// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import StakeService
import BalanceService
import NFTService
import JobRunner

public struct TransactionService: Sendable {
    private let transactionStore: TransactionStore
    private let transactionUpdateService: TransactionUpdateService
    private let runner: JobRunner

    public init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.transactionUpdateService = TransactionUpdateService(
            transactionStore: transactionStore,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: balanceUpdater,
            stakeService: stakeService,
            nftService: nftService
        )
        self.runner = JobRunner(
            config: .adaptive(
                AdaptiveConfiguration(
                    idleInterval: .seconds(5),
                    maxInterval: .seconds(10),
                    stepFactor: 1.5
                )
            )
        )
    }

    public func setup() {
        if let pendingTransactions = try? transactionStore.getTransactions(state: .pending) {
            runUpdate(for: pendingTransactions)
        }
    }

    public func addTransactions(walletId: String, transactions: [Transaction]) throws {
        try transactionStore.addTransactions(walletId: walletId, transactions: transactions)
        let pendingTransactions = transactions.filter({ $0.state.isPending })
        runUpdate(for: pendingTransactions)
    }
}

// MARK: - Private

extension TransactionService {
    private func runUpdate(for pendingTransactions: [Transaction]) {
        let jobs = pendingTransactions.map {
            TransactionUpdateJob(
                transaction: $0,
                action: transactionUpdateService.execute(for:)
            )
        }
        Task {
            for job in jobs {
                await runner.addJob(job: job)
            }
        }
    }
}

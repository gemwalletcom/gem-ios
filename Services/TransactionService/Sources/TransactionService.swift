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
    private let stateService: TransactionStateService
    private let postProcessingService: TransactionStateUpdatePostJob
    private let runner: JobRunner = JobRunner()

    public init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.stateService = TransactionStateService(
            transactionStore: transactionStore,
            chainServiceFactory: chainServiceFactory
        )
        self.postProcessingService = TransactionStateUpdatePostJob(
            transactionStore: transactionStore,
            balanceUpdater: balanceUpdater,
            stakeService: stakeService,
            nftService: nftService
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
            TransactionStateUpdateJob(
                transaction: $0,
                stateService: stateService,
                postProcessingService: postProcessingService
            )
        }
        Task {
            for job in jobs {
                await runner.addJob(job: job)
            }
        }
    }
}

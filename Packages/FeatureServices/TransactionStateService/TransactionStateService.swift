// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import StakeService
import BalanceService
import NFTService

public struct TransactionStateService: Sendable {
    private let transactionStore: TransactionStore
    private let stateService: TransactionStateProvider
    private let postProcessingService: TransactionPostProcessingService
    private let runner: JobRunner = JobRunner()

    public init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.stateService = TransactionStateProvider(
            transactionStore: transactionStore,
            chainServiceFactory: chainServiceFactory
        )
        self.postProcessingService = TransactionPostProcessingService(
            transactionStore: transactionStore,
            balanceUpdater: balanceUpdater,
            stakeService: stakeService,
            nftService: nftService
        )
    }

    public func setup() {
        if let walletsTransactions = try? transactionStore.getTransactionWallets(state: .pending) {
            runUpdate(for: walletsTransactions)
        }
    }

    public func addTransactions(wallet: Wallet, transactions: [Transaction]) throws {
        try transactionStore.addTransactions(
            walletId: wallet.walletId.id,
            transactions: transactions
        )
        runUpdate(for: transactions.map({ TransactionWallet(transaction: $0, wallet: wallet) }))
    }
}

// MARK: - Private

extension TransactionStateService {
    private func runUpdate(for transactionWallets: [TransactionWallet]) {
        let jobs = transactionWallets.map {
            TransactionStateUpdateJob(
                transactionWallet: $0,
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

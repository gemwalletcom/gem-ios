// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import ChainService
import StakeService
import BalanceService
import NFTService
import GemstonePrimitives

public struct TransactionService: Sendable {
    private let transactionStore: TransactionStore
    private let chainServiceFactory: ChainServiceFactory
    private let balanceUpdater: any BalancerUpdater
    private let stakeService: StakeService
    private let nftService: NFTService

    private let poller = TimerPoller(
        configuration: TimerPollerConfiguration(
            maxInterval: .seconds(10),
            idleInterval: .seconds(5),
            stepFactor: 1.5
        )
    )

    public init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        nftService: NFTService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.stakeService = stakeService
        self.nftService = nftService
        self.chainServiceFactory = chainServiceFactory
        self.balanceUpdater = balanceUpdater
    }

    public func setup() {
        Task {
            await poller.start(pollAction: pollPendingTransactions)
        }
    }

    public func addTransactions(walletId: String, transactions: [Transaction]) throws {
        try transactionStore.addTransactions(walletId: walletId, transactions: transactions)
        setup()
    }

    private func pollPendingTransactions() async throws -> PollResult {
        let pendingTransactions = try transactionStore.getTransactions(state: .pending)
        guard !pendingTransactions.isEmpty else {
            return .init(isActive: false, recommendedInterval: poller.configuration.idleInterval)
        }

        // Process each pending transaction
        try await updateState(pendingTransactions: pendingTransactions)

        // Check if any remain pending
        let remainPendingTransactions = try transactionStore.getTransactions(state: .pending)
        return PollResult(
            isActive: remainPendingTransactions.isNotEmpty,
            recommendedInterval: remainPendingTransactions
                .map { Duration.milliseconds(ChainConfig.config(chain: $0.assetId.chain).blockTime)}
                .min() ?? poller.configuration.idleInterval
        )
    }

    private func updateState(pendingTransactions: [Transaction]) async throws {
        await withTaskGroup(of: Void.self) { group in
            for transaction in pendingTransactions {
                group.addTask {
                    do {
                        NSLog("pending transaction: chain \(transaction.assetId.chain.rawValue), hash: \(transaction.hash)")
                        try await updateState(for: transaction)
                    } catch {
                        let timeout = ChainConfig.config(chain: transaction.assetId.chain).transactionTimeout
                        let interval = Date.now.timeIntervalSince(transaction.createdAt)
                        if interval > Double(timeout) {
                            // If update fails due to timeout, mark transaction as failed.
                            try? transactionStore.updateState(id: transaction.id, state: .failed)
                        }
                        NSLog("failed processing transaction: \(error) (chain: \(transaction.assetId.chain.rawValue), interval: \(interval)) for hash: \(transaction.hash)")
                    }
                }
            }
            await group.waitForAll()
        }
    }

    private func updateState(for transaction: Transaction) async throws {
        let assetId = transaction.assetId
        let provider = chainServiceFactory.service(for: assetId.chain)
        var transactionId = transaction.id

        let request = TransactionStateRequest(
            id: transaction.hash,
            senderAddress: transaction.from,
            recipientAddress: transaction.to,
            block: transaction.blockNumber
        )

        let stateChanges = try await provider.transactionState(for: request)
        NSLog("stateChanges: \(stateChanges)")

        try transactionStore.updateState(id: transactionId, state: stateChanges.state)

        for change in stateChanges.changes {
            switch change {
            case .networkFee(let networkFee):
                try transactionStore.updateNetworkFee(transactionId: transactionId, networkFee: networkFee.description)
            case .hashChange(_, let newHash):
                let newTransactionId = Primitives.Transaction.id(chain: assetId.chain, hash: newHash)
                try transactionStore.updateTransactionId(
                    oldTransactionId: transactionId,
                    transactionId: newTransactionId,
                    hash: newHash
                )
                transactionId = newTransactionId
            case .blockNumber(let block):
                try transactionStore.updateBlockNumber(transactionId: transactionId, block: block)
            case .createdAt(let date):
                try transactionStore.updateCreatedAt(transactionId: transactionId, date: date)
            }
        }

        NSLog("pending transactions: state: \(stateChanges.state.rawValue), chain \(assetId.chain.rawValue), for: (\(transaction.hash))")

        if stateChanges.state != .pending {
            let assetIds = (transaction.assetIds + [transaction.feeAssetId]).unique()
            let walletIds = try transactionStore.getWalletIds(for: transactionId)

            for assetId in assetIds {
                for walletId in walletIds {
                    Task {
                        do {
                            try await balanceUpdater.updateBalance(
                                walletId: walletId,
                                asset: assetId,
                                address: transaction.from
                            )
                        } catch {
                            NSLog("Error updating balance for wallet \(walletId): \(error)")
                        }
                    }

                    if [TransactionType.stakeDelegate, .stakeUndelegate, .stakeRewards].contains(transaction.type) {
                        Task {
                            do {
                                try await stakeService.update(
                                    walletId: walletId,
                                    chain: assetId.chain,
                                    address: transaction.from
                                )
                            } catch {
                                NSLog("Error updating stake for wallet \(walletId): \(error)")
                            }
                        }
                    }

                    if [TransactionType.transferNFT].contains(transaction.type) {
                        // TODO: Add NFT update logic here.
                    }
                }
            }
        }
    }
}

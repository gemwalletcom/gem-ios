// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import StakeService
import BalanceService
import NFTService
import GemstonePrimitives
import Blockchain

public struct TransactionUpdater: Sendable {
    private let transactionStore: TransactionStore
    private let chainServiceFactory: ChainServiceFactory
    private let balanceUpdater: any BalancerUpdater
    private let stakeService: StakeService
    private let nftService: NFTService

    public init(
        transactionStore: TransactionStore,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: any BalancerUpdater,
        stakeService: StakeService,
        nftService: NFTService
    ) {
        self.transactionStore = transactionStore
        self.chainServiceFactory = chainServiceFactory
        self.balanceUpdater = balanceUpdater
        self.stakeService = stakeService
        self.nftService = nftService
    }

    public func update(pendingTransactions: [Transaction]) async throws -> [Transaction] {
        var updatedTransactions = pendingTransactions
        await withTaskGroup(of: (Int, Transaction).self) { group in
            for (index, transaction) in pendingTransactions.enumerated() {
                group.addTask {
                    do {
                        let updatedTransaction = try await update(for: transaction)
                        return (index, updatedTransaction)
                    } catch {
                        let failedTransaction = handleFailure(transaction, error: error)
                        return (index, failedTransaction)
                    }
                }
            }

            for await (index, transaction) in group {
                updatedTransactions[index] = transaction
            }
        }

        return updatedTransactions
    }
}

// MARK: - Private

extension TransactionUpdater {
    private func update(for transaction: Transaction) async throws -> Transaction {
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
        return transaction.withState(stateChanges.state)
    }

    private func handleFailure(_ transaction: Transaction, error: Error) -> Transaction {
        let timeoutDuration = ChainConfig.config(chain: transaction.assetId.chain).transactionTimeout
        let elapsedTime = Date.now.timeIntervalSince(transaction.createdAt)
        if elapsedTime > Double(timeoutDuration) {
            try? transactionStore.updateState(id: transaction.id, state: .failed)
            return transaction.withState(.failed)
        }
        NSLog("Failed updating transaction (\(transaction.hash)): \(error). Chain: \(transaction.assetId.chain.rawValue), elapsed time: \(elapsedTime)")
        return transaction
    }
}

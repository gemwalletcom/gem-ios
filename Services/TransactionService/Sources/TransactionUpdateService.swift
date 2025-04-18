// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import StakeService
import BalanceService
import NFTService
import Blockchain
import GemstonePrimitives

struct TransactionUpdateService: Sendable {
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

    public func execute(for transaction: Transaction) async -> (TransactionState, Duration) {
        do {
            guard transaction.state == .pending else {
                return (transaction.state, .zero)
            }

            let request = TransactionStateRequest(
                id: transaction.hash,
                senderAddress: transaction.from,
                recipientAddress: transaction.to,
                block: transaction.blockNumber
            )
            let chainService = chainServiceFactory.service(for: transaction.assetId.chain)
            let stateChanges = try await chainService.transactionState(for: request)

            try transactionStore.updateState(
                id: transaction.id,
                state: stateChanges.state
            )

            for change in stateChanges.changes {
                switch change {
                case .networkFee(let networkFee):
                    try transactionStore.updateNetworkFee(
                        transactionId: transaction.id,
                        networkFee: networkFee.description
                    )
                case .hashChange(_, let newHash):
                    let newTransactionId = Primitives.Transaction.id(chain: transaction.assetId.chain, hash: newHash)
                    try transactionStore.updateTransactionId(
                        oldTransactionId: transaction.id,
                        transactionId: newTransactionId,
                        hash: newHash
                    )
                case .blockNumber(let block):
                    try transactionStore.updateBlockNumber(transactionId: transaction.id, block: block)
                case .createdAt(let date):
                    try transactionStore.updateCreatedAt(transactionId: transaction.id, date: date)
                }
            }

            if stateChanges.state == .pending {
                return (.pending, .milliseconds(ChainConfig.config(chain: transaction.assetId.chain).blockTime))
            }

            // async update balances, etc.. based on finished transaction
            try finalizeUpdate(for: transaction)

            return (stateChanges.state, .zero)
        } catch {
            return handleFailure(transaction: transaction)
        }
    }

    private func handleFailure(transaction: Transaction) -> (TransactionState, Duration) {
        let config = ChainConfig.config(chain: transaction.assetId.chain)
        let timeoutDuration = config.transactionTimeout
        let elapsedTime = Date.now.timeIntervalSince(transaction.createdAt)

        if elapsedTime > Double(timeoutDuration) {
            try? transactionStore.updateState(id: transaction.id, state: .failed)
            return (.failed, .zero)
        } else {
            return (.pending, .milliseconds(config.blockTime))
        }
    }

    // TODO: - possibly move to a different service
    private func finalizeUpdate(for transaction: Transaction) throws {
        let assetIds = (transaction.assetIds + [transaction.feeAssetId]).unique()
        let walletIds = try transactionStore.getWalletIds(for: transaction.id)

        // For each wallet ID, perform stake/balance/NFT updates in separate tasks
        for walletId in walletIds {
            for assetId in assetIds {
                // Update balances
                Task {
                    do {
                        try await balanceUpdater.updateBalance(walletId: walletId, asset: assetId, address: transaction.from)
                    } catch {
                        NSLog("Error updating balance for wallet \(walletId): \(error)")
                    }
                }

                // Update stake / NFT logic based on transaction type
                switch transaction.type {
                case .stakeDelegate, .stakeUndelegate, .stakeRewards:
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
                case .transferNFT:
                    Task {
                        // NFT update logic
                    }
                default:
                    // No additional action needed
                    break
                }
            }
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import Blockchain

struct TransactionStateService: Sendable {
    private let transactionStore: TransactionStore
    private let chainServiceFactory: ChainServiceFactory

    public init(
        transactionStore: TransactionStore,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.transactionStore = transactionStore
        self.chainServiceFactory = chainServiceFactory
    }

    public func getState(for transaction: Transaction) async throws -> TransactionChanges {
        let chainService = chainServiceFactory.service(for: transaction.assetId.chain)
        return try await chainService.transactionState(
            for: TransactionStateRequest(
                id: transaction.id.identifier,
                senderAddress: transaction.from,
                recipientAddress: transaction.to,
                block: try Int.from(string: transaction.blockNumber ?? "0"),
                createdAt: transaction.createdAt
            )
        )
    }

    public func updateStateChanges(_ stateChanges: TransactionChanges, for transaction: Transaction) async throws {
        NSLog("updateStateChanges for \(transaction.id), \(stateChanges)")

        try updateState(
            state: stateChanges.state,
            for: transaction
        )

        for change in stateChanges.changes {
            let transactionId = transaction.id.identifier
            switch change {
            case .networkFee(let networkFee):
                try transactionStore.updateNetworkFee(
                    transactionId: transaction.id.identifier,
                    networkFee: networkFee.description
                )
            case .hashChange(_, let newHash):
                let newTransactionId = Primitives.Transaction.id(chain: transaction.assetId.chain, hash: newHash)
                try transactionStore.updateTransactionId(
                    oldTransactionId: transactionId,
                    transactionId: newTransactionId,
                    hash: newHash
                )
            case .blockNumber(let block):
                try transactionStore.updateBlockNumber(transactionId: transactionId, block: block)
            case .createdAt(let date):
                try transactionStore.updateCreatedAt(transactionId: transactionId, date: date)
            case .metadata(let metadata):
                try transactionStore.updateMetadata(transactionId: transactionId, metadata: metadata)
            }
        }
    }

    public func updateState(state: TransactionState, for transaction: Transaction) throws {
        try transactionStore.updateState(
            id: transaction.id.identifier,
            state: state
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Blockchain
import Gemstone

class TransactionService {
    
    let transactionStore: TransactionStore
    let chainServiceFactory: ChainServiceFactory
    let balanceUpdater: BalancerUpdater
    let stakeService: StakeService
    
    init(
        transactionStore: TransactionStore,
        stakeService: StakeService,
        chainServiceFactory: ChainServiceFactory,
        balanceUpdater: BalancerUpdater
    ) {
        self.transactionStore = transactionStore
        self.stakeService = stakeService
        self.chainServiceFactory = chainServiceFactory
        self.balanceUpdater = balanceUpdater
    }
    
    func addTransaction(walletId: String, transaction: Transaction) throws {
        try transactionStore.addTransactions(walletId: walletId, transactions: [transaction])
    }
    
    func updatePendingTransactions() async throws {
        let transactions = try transactionStore.getTransactions(state: .pending)
        
        for transaction in transactions {
            Task {
                do {
                    NSLog("pending transactions request: chain \(transaction.assetId.chain.rawValue), for: (\(transaction.hash))")
                    try await updateState(for: transaction)
                } catch {
                    let timeout = Gemstone.chainTransactionTimeoutSeconds(chain: transaction.assetId.chain.rawValue)
                    let interval = Date.now.timeIntervalSince(transaction.createdAt)
                    if interval > timeout {
                        let _ = try transactionStore.updateState(id: transaction.id, state: .failed)
                    }
                    NSLog("pending transactions request: failed: \(error), chain \(transaction.assetId.chain.rawValue), interval: \(interval) for: (\(transaction.hash)")
                }
            }
        }
    }
    
    func updateState(for transaction: Transaction) async throws {
        let assetId = transaction.assetId
        let provider = chainServiceFactory.service(for: assetId.chain)
        var transactionId = transaction.id
        
        let stateChanges = try await provider.transactionState(for: transaction.hash, senderAddress: transaction.from)
        // update state changes
        
        NSLog("stateChanges: \(stateChanges)")
        
        let _ = try transactionStore.updateState(id: transactionId, state: stateChanges.state)
        
        for change in stateChanges.changes {
            switch change {
            case .networkFee(let bigInt):
                try transactionStore.updateNetworkFee(transactionId: transactionId, networkFee: bigInt.description)
            case .hashChange(_, let newHash):
                let newTransactionId = Primitives.Transaction.id(chain: assetId.chain.rawValue, hash: newHash)
                try transactionStore.updateTransactionId(
                    oldTransactionId: transactionId,
                    transactionId: newTransactionId,
                    hash: newHash
                )
                transactionId = newTransactionId
            }
        }
        
        NSLog("pending transactions: state: \(stateChanges.state.rawValue), chain \(assetId.chain.rawValue), for: (\(transaction.hash))")
        
        if stateChanges.state != .pending  {
            let assetIds = (transaction.assetIds + [transaction.feeAssetId]).unique()
            let walletIds = try transactionStore.getWalletIds(for: transactionId)
            
            assetIds.forEach { assetId in
                for walletId in walletIds {
                    Task {
                        await balanceUpdater
                            .updateBalance(
                                walletId: walletId,
                                asset: assetId,
                                address: transaction.from
                            )
                    }
                    if [TransactionType.stakeDelegate, .stakeUndelegate, .stakeRewards].contains(transaction.type) {
                        Task {
                            try await stakeService.update(walletId: walletId, chain: assetId.chain, address: transaction.from)
                        }
                    }
                    
                }
            }
        }
    }
}

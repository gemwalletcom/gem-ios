// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store

class TransactionsService {
    
    let provider: GemAPITransactionService
    let transactionStore: TransactionStore
    let assetsService: AssetsService
    
    init(
        provider: GemAPITransactionService = GemAPIService(),
        transactionStore: TransactionStore,
        assetsService: AssetsService
    ) {
        self.provider = provider
        self.transactionStore = transactionStore
        self.assetsService = assetsService
    }
    
    func updateAll(deviceId: String, wallet: Wallet) async throws {
        let store = WalletPreferencesStore(walletId: wallet.id)
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        
        let transactions = try await provider.getTransactionsAll(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            fromTimestamp: store.transactionsTimestamp
        )
        try await prefetchAssets(walletId: wallet.walletId, transactions: transactions)
        try transactionStore.addTransactions(walletId: wallet.id, transactions: transactions)
        
        store.transactionsTimestamp = newTimestamp
    }
    
    func updateForAsset(deviceId: String, wallet: Wallet, assetId: AssetId) async throws {
        let store = WalletPreferencesStore(walletId: wallet.id)
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        
        let transactions = try await provider.getTransactionsForAsset(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            asset: assetId,
            fromTimestamp: store.transactionsForAssetTimestamp(assetId: assetId.identifier)
        )
        if transactions.isEmpty {
            return
        }
        try await prefetchAssets(walletId: wallet.walletId, transactions: transactions)

        try transactionStore.addTransactions(walletId: wallet.id, transactions: transactions)
        
        store.setTransactionsForAssetTimestamp(assetId: assetId.identifier, value: newTimestamp)
    }
    
    private func prefetchAssets(walletId: WalletId, transactions: [Transaction]) async throws {
        let assetIds = transactions.map { $0.assetIds }.flatMap { $0 }
        if assetIds.isEmpty {
            return
        }
        let newAssets = try await assetsService.prefetchAssets(assetIds: assetIds)
        try assetsService.addBalancesIfMissing(walletId: walletId, assetIds: newAssets)
    }
}

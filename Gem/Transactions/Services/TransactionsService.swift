// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import Keystore
import Combine

class TransactionsService {

    let provider: any GemAPITransactionService
    let transactionStore: TransactionStore
    let assetsService: AssetsService
    let keystore: any Keystore

    init(
        provider: any GemAPITransactionService = GemAPIService(),
        transactionStore: TransactionStore,
        assetsService: AssetsService,
        keystore: any Keystore
    ) {
        self.provider = provider
        self.transactionStore = transactionStore
        self.assetsService = assetsService
        self.keystore = keystore
    }

    func updateAll(deviceId: String, walletId: WalletId) async throws {
        let wallet = try keystore.getWallet(walletId)
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

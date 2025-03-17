// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import Combine
import Preferences
import AssetsService

public final class TransactionsService: Sendable {
    let provider: any GemAPITransactionService
    public let transactionStore: TransactionStore
    let assetsService: AssetsService
    let walletStore: WalletStore

    public init(
        provider: any GemAPITransactionService = GemAPIService(),
        transactionStore: TransactionStore,
        assetsService: AssetsService,
        walletStore: WalletStore
    ) {
        self.provider = provider
        self.transactionStore = transactionStore
        self.assetsService = assetsService
        self.walletStore = walletStore
    }

    public func updateAll(deviceId: String, walletId: WalletId) async throws {
        guard let wallet = try walletStore.getWallet(id: walletId.id) else {
            throw AnyError("Can't get a wallet, walletId: \(walletId.id)")
        }
        let store = WalletPreferences(walletId: wallet.id)
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
    
    public func updateForAsset(deviceId: String, wallet: Wallet, assetId: AssetId) async throws {
        let store = WalletPreferences(walletId: wallet.id)
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

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import Preferences
import AssetsService
import DeviceService
import SwapService

public final class TransactionsService: Sendable {
    let provider: any GemAPITransactionService
    public let transactionStore: TransactionStore
    let assetsService: AssetsService
    let walletStore: WalletStore
    private let deviceService: any DeviceServiceable
    private let addressStore: AddressStore
    private let swapTransactionService: any SwapStatusProviding
    private let swapStatusTasks = SwapStatusTaskManager()
    
    public init(
        provider: any GemAPITransactionService = GemAPIService(),
        transactionStore: TransactionStore,
        assetsService: AssetsService,
        walletStore: WalletStore,
        deviceService: any DeviceServiceable,
        addressStore: AddressStore,
        swapTransactionService: any SwapStatusProviding
    ) {
        self.provider = provider
        self.transactionStore = transactionStore
        self.assetsService = assetsService
        self.walletStore = walletStore
        self.deviceService = deviceService
        self.addressStore = addressStore
        self.swapTransactionService = swapTransactionService
    }

    public func updateAll(walletId: WalletId) async throws {
        guard let wallet = try walletStore.getWallet(id: walletId.id) else {
            throw AnyError("Can't get a wallet, walletId: \(walletId.id)")
        }
        let store = WalletPreferences(walletId: wallet.id)
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        
        let deviceId = try await deviceService.getSubscriptionsDeviceId()
        let response = try await provider.getTransactionsAll(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            fromTimestamp: store.transactionsTimestamp
        )
        
        try await prefetchAssets(walletId: wallet.walletId, transactions: response.transactions)
        try transactionStore.addTransactions(walletId: wallet.id, transactions: response.transactions)
        try addressStore.addAddressNames(response.addressNames)
        
        store.transactionsTimestamp = newTimestamp
        monitorSwapStatuses(for: response.transactions)
    }
    
    public func updateForAsset(wallet: Wallet, assetId: AssetId) async throws {
        let store = WalletPreferences(walletId: wallet.id)
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let deviceId = try await deviceService.getSubscriptionsDeviceId()
        let response = try await provider.getTransactionsForAsset(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            asset: assetId,
            fromTimestamp: store.transactionsForAssetTimestamp(assetId: assetId.identifier)
        )
        if response.transactions.isEmpty {
            return
        }

        try await prefetchAssets(walletId: wallet.walletId, transactions: response.transactions)
        try transactionStore.addTransactions(walletId: wallet.id, transactions: response.transactions)
        try addressStore.addAddressNames(response.addressNames)

        store.setTransactionsForAssetTimestamp(assetId: assetId.identifier, value: newTimestamp)
        monitorSwapStatuses(for: response.transactions)
    }

    public func addTransaction(walletId: WalletId, transaction: Transaction) throws {
        try transactionStore.addTransactions(walletId: walletId.id, transactions: [transaction])
        monitorSwapStatuses(for: [transaction])
    }

    public func updateSwapResult(transactionId: String, swapResult: SwapResult) throws {
        let record = try transactionStore.getTransactionRecord(transactionId: transactionId)
        guard let metadata = record.metadata else { return }

        guard case let .swap(swapMetadata) = metadata else {
            return
        }

        let updatedMetadata = TransactionMetadata.swap(
            TransactionSwapMetadata(
                fromAsset: swapMetadata.fromAsset,
                fromValue: swapMetadata.fromValue,
                toAsset: swapMetadata.toAsset,
                toValue: swapMetadata.toValue,
                provider: swapMetadata.provider,
                swapResult: swapResult
            )
        )
        try transactionStore.updateMetadata(transactionId: transactionId, metadata: updatedMetadata)
    }
    
    public func getTransaction(walletId: WalletId, transactionId: String) throws -> TransactionExtended {
        try transactionStore.getTransaction(walletId: walletId.id, transactionId: transactionId)
    }

    public func monitorPendingSwapStatuses() {
        guard let pending = try? transactionStore.getSwapTransactionsNeedingStatusUpdate() else { return }
        monitorSwapStatuses(for: pending.map(\.transaction))
    }

    private func prefetchAssets(walletId: WalletId, transactions: [Transaction]) async throws {
        let assetIds = transactions.map { $0.assetIds }.flatMap { $0 }
        if assetIds.isEmpty {
            return
        }
        let newAssets = try await assetsService.prefetchAssets(assetIds: assetIds)
        try assetsService.addBalancesIfMissing(walletId: walletId, assetIds: newAssets)
    }

    private func monitorSwapStatuses(for transactions: [Transaction]) {
        guard !transactions.isEmpty else { return }

        Task { [weak self] in
            guard let self else { return }
            for transaction in transactions {
                guard let context = self.makeSwapStatusContext(for: transaction) else { continue }
                await self.swapStatusTasks.enqueue(id: transaction.id) {
                    await self.trackSwapStatus(using: context, transactionId: transaction.id)
                }
            }
        }
    }

    private func trackSwapStatus(using context: SwapStatusContext, transactionId: String) async {
        var backoff: Duration = .seconds(5)

        while !Task.isCancelled {
            do {
                let result = try await swapTransactionService.getSwapResult(
                    providerId: context.provider,
                    chain: context.chain,
                    transactionId: context.transactionId,
                    memo: context.identifier
                )

                do {
                    try updateSwapResult(transactionId: transactionId, swapResult: result)
                } catch {
                    NSLog("TransactionsService update swap result error: \(error)")
                }

                if result.status != .pending {
                    break
                }

                backoff = .seconds(5)
            } catch {
                NSLog("TransactionsService swap status error: \(error)")
                try? await Task.sleep(for: backoff)
                backoff = min(backoff * 2, .seconds(300))
                continue
            }

            try? await Task.sleep(for: .seconds(30))
        }
    }

    private func makeSwapStatusContext(for transaction: Transaction) -> SwapStatusContext? {
        guard case let .swap(metadata) = transaction.metadata else { return nil }
        guard let provider = metadata.provider, !provider.isEmpty else { return nil }

        if metadata.fromAsset.chain == metadata.toAsset.chain {
            return nil
        }

        if let swapResult = metadata.swapResult, swapResult.status != .pending {
            return nil
        }

        let identifier: String?
        if provider.lowercased() == SwapProvider.nearIntents.rawValue.lowercased() {
            identifier = transaction.to
        } else {
            identifier = transaction.memo
        }

        return SwapStatusContext(
            provider: provider,
            chain: transaction.assetId.chain,
            transactionId: transaction.hash,
            identifier: identifier
        )
    }
}

private struct SwapStatusContext {
    let provider: String
    let chain: Chain
    let transactionId: String
    let identifier: String?
}

private actor SwapStatusTaskManager {
    private var tasks: [String: Task<Void, Never>] = [:]

    func enqueue(id: String, operation: @escaping () async -> Void) {
        guard tasks[id] == nil else { return }
        tasks[id] = Task {
            await operation()
            await self.removeTask(id: id)
        }
    }

    private func removeTask(id: String) {
        tasks[id] = nil
    }
}

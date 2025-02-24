// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import Keystore
import BannerService
import PriceService
import Preferences
import BalanceService
import AssetsService
import TransactionService
import DiscoverAssetsService
import struct ChainService.AddressStatusService

public final class WalletsService: Sendable {
    public let assetsService: AssetsService
    public let priceService: PriceService
    public let keystore: any Keystore
    public let balanceService: BalanceService

    private let addressStatusService: AddressStatusService
    private let discoverAssetService: DiscoverAssetsService
    private let transactionService: TransactionService
    private let bannerSetupService: BannerSetupService
    private let preferences: Preferences

    public init(
        keystore: any Keystore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        discoverAssetService: DiscoverAssetsService,
        transactionService: TransactionService,
        bannerSetupService: BannerSetupService,
        addressStatusService: AddressStatusService,
        preferences: Preferences = .standard
    ) {
        self.keystore = keystore
        self.assetsService = assetsService
        self.balanceService = balanceService
        self.priceService = priceService
        self.discoverAssetService = discoverAssetService
        self.transactionService = transactionService
        self.bannerSetupService = bannerSetupService
        self.addressStatusService = addressStatusService
        self.preferences = preferences
    }

    public func enableAssetId(walletId: WalletId, assets: [AssetId], enabled: Bool) async {
        do {
            for assetId in assets {
                try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
                try assetsService.updateEnabled(walletId: walletId, assetId: assetId, enabled: enabled)
            }
            if enabled {
                async let balanceUpdate: () = updateBalance(for: walletId, assetIds: assets)
                async let priceUpdate: () = updatePrices(assetIds: assets)
                _ = try await (balanceUpdate, priceUpdate)
            }
        } catch {
            NSLog("enableAssetId: \(error)")
        }
    }

    public func changeCurrency(walletId: WalletId) async throws {
        // TODO: - here need a cancel logic if updatePrices & updateBalance in progress, but someone changes in one more time
        // updates prices
        try priceService.clear()
        let assetIds = try assetsService.getAssets().assetIds
        try await updatePrices(assetIds: assetIds)
        // update balances
        let enabledAssetIds = try assetsService.getEnabledAssets()
        try await updateBalance(for: walletId, assetIds: enabledAssetIds)
    }

    public func updateAsset(walletId: WalletId, assetId: AssetId) async throws {
        async let getBalance: () = try updateBalance(for: walletId, assetIds: [assetId])
        async let getPrice: () = try updatePrices(assetIds: [assetId])

        let (_, _) =  try await (getBalance, getPrice)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        let wallet = try keystore.getWallet(walletId)
        async let balances: () = try updateBalance(for: walletId, assetIds: assetIds)
        async let prices: () = try updatePrices(assetIds: assetIds)
        async let newAssets: () = try getNewAssets(for: wallet)
        let _ = try await [balances, prices, newAssets]
    }

    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        await self.balanceService.updateBalance(
            for: try keystore.getWallet(walletId),
            assetIds: assetIds
        )
    }

    public func updatePrices(assetIds: [AssetId]) async throws {
        let prices = try await priceService.fetchPrices(for: assetIds.ids, currency: preferences.currency)
        try priceService.updatePrices(prices: prices)
    }

    public func updatePrices() async throws {
        try await updatePrices(
            assetIds: try assetsService.getEnabledAssets()
        )
    }

    public func setupWallet(_ wallet: Wallet) throws {
        try enableAssetBalances(wallet: wallet, chains: wallet.chains)
    }

    public func addTransactions(walletId: String, transactions: [Primitives.Transaction]) throws {
        try transactionService.addTransactions(walletId: walletId, transactions: transactions)
    }

    // In the future move into separate service
    public func runAddressStatusCheck(_ wallet: Wallet) async {
        guard !wallet.preferences.completeInitialAddressStatus else { return }

        do {
            let results = try await addressStatusService.getAddressStatus(accounts: wallet.accounts)

            for (account, statuses) in results {
                if statuses.contains(.multiSignature) {
                    try bannerSetupService.setupAccountMultiSignatureWallet(walletId: wallet.walletId, chain: account.chain)
                }
            }
            wallet.preferences.completeInitialAddressStatus = true
        } catch {
            NSLog("runAddressStatusCheck: \(error)")
        }
    }

    private func update(walletId: WalletId) async throws {
        let assetIds = try assetsService
            .getAssets(walletID: walletId.id, filters: [.enabled])
            .map { $0.asset.id }
        try await fetch(walletId: walletId, assetIds: assetIds)
    }

    // add asset to asset store and create balance store record
    private func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }

    private func getNewAssets(for wallet: Wallet) async throws {
        guard wallet.hasTokenSupport else { return }
        let prefs = wallet.preferences

        async let coinProcess: () = processCoinDiscovery(for: wallet, prefs: prefs)
        async let tokenProcess: () = processTokenDiscovery(for: wallet, prefs: prefs)
        _ = try await (coinProcess, tokenProcess)
    }

    private func processCoinDiscovery(for wallet: Wallet, prefs: WalletPreferences) async throws {
        // Only perform coin discovery if it hasn’t been done before.
        if !prefs.completeInitialLoadAssets {
            let coinUpdates = await discoverAssetService.updateCoins(wallet: wallet)
            await processAssetUpdates(coinUpdates)
            prefs.completeInitialLoadAssets = true
        }
    }

    private func processTokenDiscovery(for wallet: Wallet, prefs: WalletPreferences) async throws {
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        let tokenUpdates = try await discoverAssetService.updateTokens(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: prefs.assetsTimestamp
        )
        prefs.assetsTimestamp = newTimestamp
        await processAssetUpdates(tokenUpdates)
    }

    private func processAssetUpdates(_ updates: [AssetUpdate]) async {
        await withTaskGroup(of: Void.self) { group in
            for update in updates {
                group.addTask { [weak self] in
                    guard let self else { return }
                    NSLog("discover assets: \(update.walletId): \(update.assets)")
                    do {
                        try await self.addNewAssets(
                            walletId: update.walletId,
                            assetIds: update.assets.compactMap { try? AssetId(id: $0) }
                        )
                    } catch {
                        NSLog("newAssetUpdate error: \(error)")
                    }
                }
            }
            for await _ in group { }
        }
    }

    // add fresh new asset: fetch asset and then activate balance
    private func addNewAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        let assets = try assetsService.getAssets(for: assetIds)
        let missingIds = assetIds.asSet().subtracting(assets.map { $0.id }.asSet())

        async let enableExisting: () = enableAssetId(walletId: walletId, assets: assets.assetIds, enabled: true)
        async let processMissing: () = withThrowingTaskGroup(of: Void.self) { group in
            for assetId in missingIds {
                group.addTask { [weak self] in
                    guard let self else { return }
                    try await self.assetsService.updateAsset(assetId: assetId)
                    await self.enableAssetId(walletId: walletId, assets: [assetId], enabled: true)
                }
            }
            for try await _ in group { }
        }
        _ = try await (enableExisting, processMissing)
    }

    private func enableAssetBalances(wallet: Wallet, chains: [Chain]) throws {
        try addAssetsBalancesIfMissing(assetIds: chains.ids, wallet: wallet)
    }
}

// MARK: - Models extensions

extension Wallet {
    var preferences: WalletPreferences {
        WalletPreferences(walletId: id)
    }
}

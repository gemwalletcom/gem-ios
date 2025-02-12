// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Combine
@preconcurrency import Keystore
import BannerService
import PriceService
import Preferences
import BalanceService
import AssetsService
import TransactionService
import DiscoverAssetsService
import GemstonePrimitives
import struct ChainService.AddressStatusService

// TODO: - removed @unchecked Sendable by removing var, when adopted
public final class WalletsService: @unchecked Sendable {
    public let assetsService: AssetsService
    public let priceService: PriceService
    public let keystore: any Keystore
    public let balanceService: BalanceService

    private let addressStatusService: AddressStatusService
    private let discoverAssetService: DiscoverAssetsService
    private let transactionService: TransactionService
    private let bannerSetupService: BannerSetupService
    private let preferences: Preferences

    // TODO: - omit combine
    private var assetObserver: AnyCancellable?

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

        defer {
            self.assetObserver = discoverAssetService.observeAssets().sink { update in
                NSLog("discover assets: \(update.wallet.name): \(update.assets)")

                do {
                    try self.addNewAssets(walletId: update.wallet.walletId, assetIds: update.assets.compactMap { try? AssetId(id: $0) })
                } catch {
                    NSLog("newAssetUpdate error: \(error)")
                }
            }
        }
    }

    public func enableAssetId(walletId: WalletId, assets: [AssetId], enabled: Bool) {
        do {
            for assetId in assets {
                try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
                try assetsService.updateEnabled(walletId: walletId, assetId: assetId, enabled: enabled)
            }
            if enabled {
                Task {
                    try await updateBalance(for: walletId, assetIds: assets)
                }
                Task {
                    try await updatePrices(assetIds: assets)
                }
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

    public func setupWallet(_ wallet: Wallet) throws {
        try enableAssetBalances(wallet: wallet, chains: wallet.chains)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        let wallet = try keystore.getWallet(walletId)
        async let balances: () = try updateBalance(for: walletId, assetIds: assetIds)
        async let prices: () = try updatePrices(assetIds: assetIds)
        async let newAssets: () = try getNewAssets(for: wallet)
        let _ = try await [balances, prices, newAssets]
    }

    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        balanceService.updateBalance(
            for: try keystore.getWallet(walletId),
            assetIds: assetIds
        )
    }

    public func updatePrices() async throws {
        try await updatePrices(
            assetIds: try assetsService.getEnabledAssets()
        )
    }

    public func updatePrices(assetIds: [AssetId]) async throws {
        let prices = try await priceService.fetchPrices(for: assetIds.ids, currency: self.preferences.currency)
        try priceService.updatePrices(prices: prices)
    }

    // transactions

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

    func update(walletId: WalletId) async throws {
        let assetIds = try assetsService
            .getAssets(walletID: walletId.id, filters: [.enabled])
            .map { $0.asset.id }
        try await fetch(walletId: walletId, assetIds: assetIds)
    }

    // add asset to asset store and create balance store record
    func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }

    func getNewAssets(for wallet: Wallet) async throws {
        guard wallet.hasTokenSupport else { return }

        let preferences = wallet.preferences

        Task {
            if !preferences.completeInitialLoadAssets {
                await discoverAssetService.updateCoins(wallet: wallet)
                preferences.completeInitialLoadAssets = true
            }
        }

        //FIXME: temp solution to wait for 1 second (need to wait until subscriptions updated)
        //otherwise it would return no assets
        try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))

        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)

        Task {
            try await discoverAssetService.updateTokens(
                deviceId: deviceId,
                wallet: wallet,
                fromTimestamp: preferences.assetsTimestamp
            )
            preferences.assetsTimestamp = newTimestamp
        }
    }

    // add fresh new asset: fetch asset and then activate balance
    func addNewAssets(walletId: WalletId, assetIds: [AssetId]) throws {
        let assets = try assetsService.getAssets(for: assetIds)
        let missingIds = assetIds.asSet().subtracting(assets.map { $0.id }.asSet())

        // enable that already exist in db
        if !assets.isEmpty {
            enableAssetId(walletId: walletId, assets: assets.assetIds, enabled: true)
        }

        // fetch and enable
        for assetId in missingIds {
            Task {
                try await assetsService.updateAsset(assetId: assetId)
                enableAssetId(walletId: walletId, assets: [assetId], enabled: true)
            }
        }
    }

    func enableAssetBalances(wallet: Wallet, chains: [Chain]) throws {
        try addAssetsBalancesIfMissing(assetIds: chains.ids, wallet: wallet)
    }
}

// MARK: - Models extensions

extension Wallet {
    var preferences: WalletPreferences {
        WalletPreferences(walletId: id)
    }
}

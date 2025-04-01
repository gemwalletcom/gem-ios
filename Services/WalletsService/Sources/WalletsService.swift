// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BannerService
import PriceService
import Preferences
import BalanceService
import AssetsService
import TransactionService
import DiscoverAssetsService
import ChainService
import Store
import WalletSessionService

public struct WalletsService: Sendable {
    // TODO: - remove public dependencies and remove them in future
    public let assetsService: AssetsService
    public let priceService: PriceService
    public let balanceService: BalanceService

    private let walletSessionService: any WalletSessionManageable
    private let discoveryProcessor: any DiscoveryAssetsProcessing
    private let assetsEnabler: any AssetsEnabler
    private let priceUpdater: any PriceUpdater
    private let balanceUpdater: any BalanceUpdater
    private let currencyUpdater: any CurrencyUpdater
    private let assetsVisibilityManager: any AssetVisibilityManageable

    // TODO: - move to different place
    private let addressStatusService: AddressStatusService
    private let transactionService: TransactionService
    private let bannerSetupService: BannerSetupService

    public init(
        walletStore: WalletStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        chainService: ChainServiceFactory,
        transactionService: TransactionService,
        bannerSetupService: BannerSetupService,
        addressStatusService: AddressStatusService,
        preferences: ObservablePreferences = .default
    ) {

        let walletSessionService = WalletSessionService(walletStore: walletStore, preferences: preferences)
        let balanceUpdater = BalanceUpdateService(
            balanceService: balanceService,
            walletSessionService: walletSessionService
        )
        let priceUpdater = PriceUpdateService(priceService: priceService, preferences: preferences.preferences)

        let currencyUpdateService = CurrencyUpdateService(
            assetsService: assetsService,
            balanceUpdater: balanceUpdater,
            priceUpdater: priceUpdater
        )

        let assetsEnabler = AssetsEnablerService(
            assetsService: assetsService,
            balanceUpdater: balanceUpdater,
            priceUpdater: priceUpdater
        )
        let processor = DiscoveryAssetsProcessor(
            discoverAssetService: DiscoverAssetsService(
                balanceService: balanceService,
                chainServiceFactory: chainService
            ),
            assetsService: assetsService,
            assetsEnabler: assetsEnabler,
            walletSessionService: walletSessionService
        )
        self.assetsVisibilityManager = AssetVisibilityManager(service: balanceService)
        self.assetsEnabler = assetsEnabler
        self.balanceUpdater = balanceUpdater
        self.priceUpdater = priceUpdater
        self.currencyUpdater = currencyUpdateService
        self.discoveryProcessor = processor


        self.assetsService = assetsService
        self.balanceService = balanceService
        self.priceService = priceService
        self.transactionService = transactionService
        self.bannerSetupService = bannerSetupService
        self.addressStatusService = addressStatusService
        self.walletSessionService = walletSessionService
    }

    public func walletsCount() throws -> Int {
        try walletSessionService.getWallets().count
    }

    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        async let balances: () = try balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
        async let prices: () = try priceUpdater.updatePrices(assetIds: assetIds)

        let (_, _) =  try await (balances, prices)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        async let updateAssets: () = try updateAssets(walletId: walletId, assetIds: assetIds)
        async let assets: () = try await discoveryProcessor.discoverAssets(for: walletId, preferences: WalletPreferences(walletId: walletId.id))

        let _ = try await [updateAssets, assets]
    }

    public func updatePrices() async throws {
        try await priceUpdater.updatePrices(
            assetIds: try assetsService.getEnabledAssets()
        )
    }

    public func setup(wallet: Wallet) throws {
        try enableBalances(for: wallet.walletId, chains: wallet.chains)
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
}

// MARK: - DiscoveryAssetsProcessing

extension WalletsService: DiscoveryAssetsProcessing {
    public func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        try await discoveryProcessor.discoverAssets(for: walletId, preferences: preferences)
    }
}

// MARK: - AssetsEnabler

extension WalletsService: AssetsEnabler {
    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async {
        await assetsEnabler.enableAssets(walletId: walletId, assetIds: assetIds, enabled: enabled)
    }
}

// MARK: - CurrencyUpdater

extension WalletsService: CurrencyUpdater {
    public func changeCurrency(for walletId: WalletId) async throws {
        try await currencyUpdater.changeCurrency(for: walletId)
    }
}

// MARK: - PriceUpdater

extension WalletsService: PriceUpdater {
    public func updatePrices(assetIds: [AssetId]) async throws {
        try await priceUpdater.updatePrices(assetIds: assetIds)
    }
}

// MARK: - BalanceUpdater


extension WalletsService: BalanceUpdater {
    public func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    func enableBalances(for walletId: WalletId, assetIds: [AssetId]) throws {
        try balanceUpdater.enableBalances(for: walletId, assetIds: assetIds)
    }
}

// MARK: - AssetVisibilityManager

extension WalletsService: AssetVisibilityManageable {
    public func togglePin(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.togglePin(isPinned, walletId: walletId, assetId: assetId)
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.hideAsset(walletId: walletId, assetId: assetId)
    }
}

// MARK: - Models extensions

extension Wallet {
    var preferences: WalletPreferences {
        WalletPreferences(walletId: id)
    }
}

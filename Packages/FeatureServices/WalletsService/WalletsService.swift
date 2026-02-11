// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceService
import Preferences
import BalanceService
import EarnService
import AssetsService
import DiscoverAssetsService
import Store
import WalletSessionService
import DeviceService

public struct WalletsService: Sendable {
    private let walletSessionService: any WalletSessionManageable
    private let discoveryProcessor: any DiscoveryAssetsProcessing
    private let assetsEnabler: any AssetsEnabler
    private let priceUpdater: any PriceUpdater
    private let balanceUpdater: any BalanceUpdater
    private let assetsVisibilityManager: any AssetVisibilityServiceable

    public init(
        walletSessionService: WalletSessionService,
        assetsService: AssetsService,
        balanceService: BalanceService,
        earnService: any EarnServiceable,
        priceService: PriceService,
        priceObserver: PriceObserverService,
        deviceService: any DeviceServiceable,
        discoverAssetsService: DiscoverAssetsService
    ) {
        let balanceUpdater = BalanceUpdateService(
            balanceService: balanceService,
            earnService: earnService,
            walletSessionService: walletSessionService
        )
        let priceUpdater = PriceUpdateService(priceObserver: priceObserver)
        let assetsEnabler = AssetsEnablerService(
            assetsService: assetsService,
            balanceUpdater: balanceUpdater,
            priceUpdater: priceUpdater
        )
        let processor = DiscoveryAssetsProcessor(
            deviceService: deviceService,
            discoverAssetService: discoverAssetsService,
            assetService: assetsService,
            priceUpdater: priceUpdater,
            walletSessionService: walletSessionService,
            assetsEnabler: assetsEnabler
        )
        self.walletSessionService = walletSessionService
        self.assetsVisibilityManager = AssetVisibilityManager(service: balanceService)
        self.assetsEnabler = assetsEnabler
        self.balanceUpdater = balanceUpdater
        self.priceUpdater = priceUpdater
        self.discoveryProcessor = processor
    }

    public func walletsCount() throws -> Int {
        try walletSessionService.getWallets().count
    }

    public func hasMulticoinWallet() -> Bool {
        (try? walletSessionService.getWallets().contains { $0.type == .multicoin }) ?? false
    }

    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        async let updateAssets: () = try updateAssets(walletId: walletId, assetIds: assetIds)
        async let assets: () = try await discoveryProcessor.discoverAssets(for: walletId, preferences: WalletPreferences(walletId: walletId))

        let _ = try await [updateAssets, assets]
    }

    public func setup(wallet: Wallet) throws {
        let chains = wallet.chains
        
        let (chainsEnabledByDefault, chainsDisabledByDefault) = chains.reduce(into: ([Chain](), [Chain]())) { result, chain in
            if AssetConfiguration.enabledByDefault.contains(chain.assetId) || (wallet.accounts.count == 1 && chains.count == 1) {
                result.0.append(chain)
            } else {
                result.1.append(chain)
            }
        }
        
        try addBalancesIfMissing(for: wallet.walletId, assetIds: chainsEnabledByDefault.ids, isEnabled: true)
        try addBalancesIfMissing(for: wallet.walletId, assetIds: chainsDisabledByDefault.ids, isEnabled: false)
        
        let defaultAssets = chains.map { $0.defaultAssets.assetIds }.flatMap { $0 }
        try addBalancesIfMissing(for: wallet.walletId, assetIds: defaultAssets, isEnabled: false)
    }
}

// MARK: - DiscoveryAssetsProcessing

extension WalletsService: DiscoveryAssetsProcessing {
    func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        try await discoveryProcessor.discoverAssets(for: walletId, preferences: preferences)
    }
}

// MARK: - AssetsEnabler

extension WalletsService: AssetsEnabler {
    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async {
        await assetsEnabler.enableAssets(walletId: walletId, assetIds: assetIds, enabled: enabled)
    }

    public func enableAssetId(walletId: WalletId, assetId: AssetId) async {
        await assetsEnabler.enableAssetId(walletId: walletId, assetId: assetId)
    }
}

// MARK: - PriceUpdater

extension WalletsService: PriceUpdater {
    public func addPrices(assetIds: [AssetId]) async throws {
        try await priceUpdater.addPrices(assetIds: assetIds)
    }
}

// MARK: - BalanceUpdater


extension WalletsService: BalanceUpdater {
    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        try await balanceUpdater.updateBalance(for: walletId, assetIds: assetIds)
    }

    public func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {
        try balanceUpdater.addBalancesIfMissing(for: walletId, assetIds: assetIds, isEnabled: isEnabled)
    }
}

// MARK: - AssetVisibilityManager

extension WalletsService: AssetVisibilityServiceable {
    public func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.setPinned(isPinned, walletId: walletId, assetId: assetId)
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.hideAsset(walletId: walletId, assetId: assetId)
    }
}

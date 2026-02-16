// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceService
import Preferences
import BalanceService
import AssetsService
import DiscoverAssetsService
import WalletSessionService
import DeviceService

public struct WalletsService: Sendable {
    private let walletSessionService: any WalletSessionManageable
    private let assetsEnabler: any AssetsEnabler
    private let assetSyncService: WalletAssetSyncService
    private let balanceUpdater: any BalanceUpdater
    private let assetsVisibilityManager: any AssetVisibilityServiceable

    public init(
        walletSessionService: WalletSessionService,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceObserver: PriceObserverService,
        deviceService: any DeviceServiceable,
        discoverAssetsService: DiscoverAssetsService
    ) {
        let balanceUpdater = BalanceUpdateService(
            balanceService: balanceService,
            walletSessionService: walletSessionService
        )
        let priceUpdater = priceObserver
        let assetsEnabler = AssetsEnablerService(
            assetsService: assetsService,
            balanceUpdater: balanceUpdater,
            priceUpdater: priceUpdater
        )
        let assetSyncService = WalletAssetSyncService(
            deviceService: deviceService,
            discoverAssetService: discoverAssetsService,
            assetService: assetsService,
            priceUpdater: priceUpdater,
            balanceUpdater: balanceUpdater,
            assetsEnabler: assetsEnabler,
            walletSessionService: walletSessionService,
        )

        self.walletSessionService = walletSessionService
        self.assetsVisibilityManager = balanceService
        self.assetsEnabler = assetsEnabler
        self.balanceUpdater = balanceUpdater
        self.assetSyncService = assetSyncService
    }

    public func walletsCount() throws -> Int {
        try walletSessionService.getWallets().count
    }

    public func hasMulticoinWallet() -> Bool {
        (try? walletSessionService.getWallets().contains { $0.type == .multicoin }) ?? false
    }

    public func updateAssets(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await assetSyncService.updateAssets(walletId: walletId, assetIds: assetIds)
    }

    public func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        try await assetSyncService.fetch(walletId: walletId, assetIds: assetIds)
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
        try await assetSyncService.discoverAssets(for: walletId, preferences: preferences)
    }
}

// MARK: - AssetsEnabler

extension WalletsService: AssetsEnabler {
    public func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool, shouldRefresh: Bool) async throws { try await assetsEnabler.enableAssets(walletId: walletId, assetIds: assetIds, enabled: enabled, shouldRefresh: shouldRefresh) }

    public func enableAssetId(walletId: WalletId, assetId: AssetId) async throws { try await assetsEnabler.enableAssetId(walletId: walletId, assetId: assetId) }
}

// MARK: - PriceUpdater

extension WalletsService: PriceUpdater {
    public func addPrices(assetIds: [AssetId]) async throws {
        try await assetSyncService.addPrices(assetIds: assetIds)
    }
}

// MARK: - BalanceUpdater

extension WalletsService: BalanceUpdater {
    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        try await assetSyncService.updateAssets(walletId: walletId, assetIds: assetIds)
    }

    public func addBalancesIfMissing(for walletId: WalletId, assetIds: [AssetId], isEnabled: Bool?) throws {
        try balanceUpdater.addBalancesIfMissing(for: walletId, assetIds: assetIds, isEnabled: isEnabled)
    }
}

// MARK: - AssetVisibilityServiceable

extension WalletsService: AssetVisibilityServiceable {
    public func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.setPinned(isPinned, walletId: walletId, assetId: assetId)
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try assetsVisibilityManager.hideAsset(walletId: walletId, assetId: assetId)
    }
}

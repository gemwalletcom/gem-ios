// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import NodeService
import AssetsService
import Preferences
import WalletService

// OnstartService runs services before the app starts.
// See OnstartAsyncService for any background tasks to run after start
public struct OnstartService: Sendable {
    
    private let assetsService: AssetsService
    private let assetStore: AssetStore
    private let nodeStore: NodeStore
    private let preferences: Preferences
    private let walletService: WalletService
    
    public init(
        assetsService: AssetsService,
        assetStore: AssetStore,
        nodeStore: NodeStore,
        preferences: Preferences,
        walletService: WalletService
    ) {
        self.assetsService = assetsService
        self.assetStore = assetStore
        self.nodeStore = nodeStore
        self.preferences = preferences
        self.walletService = walletService
    }

    public func migrations() {
        do {
            try walletService.setup(chains: AssetConfiguration.allChains)
        } catch {
            debugLog("Setup chains: \(error)")
        }
        do {
            try ImportAssetsService(
                assetsService: assetsService,
                assetStore: assetStore,
                preferences: preferences
            ).migrate()
        } catch {
            debugLog("migrations error: \(error)")
        }
        
        if !preferences.hasCurrency, let currency = Locale.current.currency {
            preferences.currency = (Currency(rawValue: currency.identifier) ?? .usd).rawValue
        }
    }
}

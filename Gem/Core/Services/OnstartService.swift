// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import NodeService
import AssetsService
import Preferences
import ManageWalletService

// OnstartService runs services before the app starts.
// See OnstartAsyncService for any background tasks to run after start
struct OnstartService {
    
    let assetsService: AssetsService
    let assetStore: AssetStore
    let nodeStore: NodeStore
    let preferences: Preferences
    let manageWalletService: ManageWalletService

    func migrations() {
        do {
            try manageWalletService.setup(chains: AssetConfiguration.allChains)
        } catch {
            NSLog("Setup chains: \(error)")
        }
        do {
            try ImportAssetsService(
                nodeService: NodeService(nodeStore: nodeStore),
                assetsService: assetsService,
                assetStore: assetStore,
                preferences: preferences
            ).migrate()
        } catch {
            NSLog("migrations error: \(error)")
        }
        
        if !preferences.hasCurrency, let currency = Locale.current.currency {
            preferences.currency = (Currency(rawValue: currency.identifier) ?? .usd).rawValue
        }
    }
}

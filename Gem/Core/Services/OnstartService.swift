// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Keystore
import Settings
import Primitives

// OnstartService runs services before the app starts.
// See OnstartAsyncService for any background tasks to run after start

struct OnstartService {
    
    let assetsService: AssetsService
    let assetStore: AssetStore
    let nodeStore: NodeStore
    let keystore: any Keystore
    let preferences = Preferences()
    
    func migrations() {
        do {
            try CleanUpService(keystore: keystore, preferences: preferences).initialSetup()
        } catch {
            NSLog("destroy initial files error: \(error)")
        }
        
        do {
            try keystore.setupChains(chains: AssetConfiguration.allChains)
        } catch {
            NSLog("keystore setup Chains error: \(error)")
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

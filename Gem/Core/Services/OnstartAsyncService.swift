// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Keystore
import GemAPI
import Primitives

class OnstartAsyncService {
    
    let assetStore: AssetStore
    let keystore: any Keystore
    let preferences: Preferences
    let configService: GemAPIConfigService = GemAPIService()
    let service: ImportAssetsService
    let subscriptionService: SubscriptionService
    let deviceService: DeviceService
    
    var updateVersionAction: StringAction = .none
    
    init(
        assetStore: AssetStore,
        keystore: any Keystore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        subscriptionService: SubscriptionService,
        updateVersionAction: StringAction = .none
    ) {
        self.assetStore = assetStore
        self.keystore = keystore
        self.preferences = preferences
        self.service = ImportAssetsService(
            nodeService: NodeService(nodeStore: nodeStore), 
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )
        self.subscriptionService = subscriptionService
        self.deviceService = deviceService
        self.updateVersionAction = updateVersionAction
    }
    
    func migrations() async {
        do {
            let config = try await configService.getConfig()
            let versions = config.versions
            if versions.fiatAssets > preferences.fiatAssetsVersion {
                Task {
                    do {
                        try await service.updateFiatAssets()
                        NSLog("Update fiat assets version: \(versions.fiatAssets)")
                    } catch {
                        NSLog("Update fiat assets error: \(error)")
                    }
                }
            }
            
            if versions.swapAssets > preferences.swapAssetsVersion {
                Task {
                    do {
                        try await service.updateSwapAssets()
                        NSLog("Update swap assets version: \(versions.swapAssets)")
                    } catch {
                        NSLog("Update swap assets error: \(error)")
                    }
                }
            }
            
            if versions.nodes > preferences.nodesVersion {
                Task {
                    do {
                        try await service.updateNodes()
                        NSLog("Update nodes version: \(versions.nodes)")
                    } catch {
                        NSLog("Update nodes error: \(error)")
                    }
                }
            }
            let newVersion = config.app.ios.version.production
            if VersionCheck.isVersionHigher(new: newVersion, current: Bundle.main.releaseVersionNumber) {
                NSLog("Newer version available")
                updateVersionAction?(newVersion)
            }
        } catch {
            NSLog("Fetching config error: \(error)")
        }
        
        RateService().perform()
        
        Task {
            try await deviceService.update()
        }
    }
}

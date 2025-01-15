// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Keystore
import GemAPI
import Primitives
import BannerService
import DeviceService
import SwapService
import NodeService
import Preferences

class OnstartAsyncService {
    
    let assetStore: AssetStore
    let nodeStore: NodeStore
    let keystore: any Keystore
    let preferences: Preferences
    let configService: any GemAPIConfigService = GemAPIService()
    let service: ImportAssetsService
    let deviceService: DeviceService
    let bannerSetupService: BannerSetupService

    var updateVersionAction: StringAction = .none
    
    init(
        assetStore: AssetStore,
        keystore: any Keystore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        bannerSetupService: BannerSetupService,
        updateVersionAction: StringAction = .none
    ) {
        self.assetStore = assetStore
        self.nodeStore = nodeStore
        self.keystore = keystore
        self.preferences = preferences
        self.service = ImportAssetsService(
            nodeService: NodeService(nodeStore: nodeStore), 
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )
        self.deviceService = deviceService
        self.bannerSetupService = bannerSetupService
        self.updateVersionAction = updateVersionAction
    }

    func setup() {
        Task {
            await migrations()
        }
        Task {
            try bannerSetupService.setup()
        }
    }

    func setup(wallet: Wallet) {
        Task {
            try bannerSetupService.setupWallet(wallet: wallet)
        }
    }

    func migrations() async {
        do {
            // import nodes
            try AddNodeService(nodeStore: nodeStore).addNodes()

            let config = try await configService.getConfig()
            let versions = config.versions
            if versions.fiatOnRampAssets > preferences.fiatOnRampAssetsVersion || versions.fiatOffRampAssets > preferences.fiatOffRampAssetsVersion {
                Task {
                    do {
                        try await service.updateFiatAssets()
                        NSLog(
                            "Update fiat assets version: on ramp: \(versions.fiatOnRampAssets), off ramp: \(versions.fiatOffRampAssets)"
                        )
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
            if let newVersion = config.releases.first(where: { $0.store == .appStore }),
                VersionCheck.isVersionHigher(new: newVersion.version, current: Bundle.main.releaseVersionNumber) {
                    NSLog("Newer version available")
                    updateVersionAction?(newVersion.version)
            }
        } catch {
            NSLog("Fetching config error: \(error)")
        }

        RateService(preferences: preferences).perform()

        Task {
            let swappper = SwapService(nodeProvider: NodeService(nodeStore: nodeStore))
            let chains = swappper.supportedChains()
            
            try assetStore.setAssetIsSwappable(for: chains.map { $0.id }, value: true)
        }
        
        Task {
            try await deviceService.update()
        }
    }
}

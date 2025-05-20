// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives
import BannerService
import DeviceService
import SwapService
import NodeService
import Preferences
import AssetsService

public final class OnstartAsyncService: Sendable {

    private let assetStore: AssetStore
    private let nodeStore: NodeStore
    private let preferences: Preferences
    private let configService: any GemAPIConfigService
    private let importAssetsService: ImportAssetsService
    private let deviceService: DeviceService
    private let bannerSetupService: BannerSetupService
    private let releaseService: AppReleaseService

    @MainActor
    public var releaseAction: ((Release) -> Void)?

    public init(
        assetStore: AssetStore,
        nodeStore: NodeStore,
        preferences: Preferences,
        assetsService: AssetsService,
        deviceService: DeviceService,
        bannerSetupService: BannerSetupService,
        configService: any GemAPIConfigService = GemAPIService()
    ) {
        self.assetStore = assetStore
        self.nodeStore = nodeStore
        self.preferences = preferences
        self.importAssetsService = ImportAssetsService(
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )
        self.deviceService = deviceService
        self.bannerSetupService = bannerSetupService
        self.configService = configService
        self.releaseService = AppReleaseService(
            configService: configService
        )
    }

    public func setup() {
        Task {
            await migrations()
        }
        Task {
            try bannerSetupService.setup()
        }
    }

    public func setup(wallet: Wallet) {
        Task {
            try bannerSetupService.setupWallet(wallet: wallet)
        }
    }

    public func migrations() async {
        do {
            try importNodes()

            let config = try await configService.getConfig()
            updateAssetsIfNeeded(config)
            checkNewRelease(config)
        } catch {
            NSLog("Fetching config error: \(error)")
        }

        performRate()
        updateSwappableAssets()
        updateDeviceService()
    }
    
    public func skipRelease(_ version: String) {
        preferences.skippedReleaseVersion = version
    }
    
    // MARK: - Private methods
    
    private func importNodes() throws {
        try AddNodeService(nodeStore: nodeStore).addNodes()
    }
    
    private func updateAssetsIfNeeded(_ config: ConfigResponse) {
        let versions = config.versions
        if versions.fiatOnRampAssets > preferences.fiatOnRampAssetsVersion || versions.fiatOffRampAssets > preferences.fiatOffRampAssetsVersion {
            Task {
                do {
                    try await importAssetsService.updateFiatAssets()
                    NSLog("Update fiat assets version: on ramp: \(versions.fiatOnRampAssets), off ramp: \(versions.fiatOffRampAssets)")
                } catch {
                    NSLog("Update fiat assets error: \(error)")
                }
            }
        }

        if versions.swapAssets > preferences.swapAssetsVersion {
            Task {
                do {
                    try await importAssetsService.updateSwapAssets()
                    NSLog("Update swap assets version: \(versions.swapAssets)")
                } catch {
                    NSLog("Update swap assets error: \(error)")
                }
            }
        }
    }
    
    private func checkNewRelease(_ config: ConfigResponse) {
        guard let release = releaseService.release(config) else {
            return
        }
        
        if let skippedReleaseVersion = preferences.skippedReleaseVersion,
           skippedReleaseVersion == release.version {
            NSLog("Skipping newer version: \(release.version)")
            return
        }
        
        NSLog("Newer version available")
        Task { @MainActor [weak self] in
            guard let self else { return }
            releaseAction?(release)
        }
    }
    
    private func performRate() {
        RateService(preferences: preferences).perform()
    }
    
    private func updateSwappableAssets() {
        Task {
            let swappper = SwapService(nodeProvider: NodeService(nodeStore: nodeStore))
            let chains = swappper.supportedChains()
            
            try assetStore.setAssetIsSwappable(for: chains.map { $0.id }, value: true)
        }
    }
    
    private func updateDeviceService() {
        Task {
            try await deviceService.update()
        }
    }
}

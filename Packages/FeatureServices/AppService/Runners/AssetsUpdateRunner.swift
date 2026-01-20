// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import AssetsService

public struct AssetsUpdateRunner: AsyncRunnable {
    public let id = "assets_update"

    private let configService: ConfigService
    private let importAssetsService: ImportAssetsService
    private let assetsService: AssetsService
    private let swappableChainsProvider: any SwappableChainsProvider
    private let preferences: Preferences

    public init(
        configService: ConfigService,
        importAssetsService: ImportAssetsService,
        assetsService: AssetsService,
        swappableChainsProvider: any SwappableChainsProvider,
        preferences: Preferences
    ) {
        self.configService = configService
        self.importAssetsService = importAssetsService
        self.assetsService = assetsService
        self.swappableChainsProvider = swappableChainsProvider
        self.preferences = preferences
    }

    public func run() async throws {
        let chains = swappableChainsProvider.supportedChains()
        try assetsService.setSwappableAssets(for: chains)

        do {
            guard let config = await configService.getConfig() else {
                throw AnyError("Config not found")
            }
            async let fiat: () = updateFiatAssets(config: config)
            async let swap: () = updateSwapAssets(config: config)
            _ = try await (fiat, swap)
        } catch {
            debugLog("Config fetch failed: \(error)")
        }
    }

    private func updateFiatAssets(config: ConfigResponse) async throws {
        guard shouldUpdateFiatAssets(versions: config.versions) else { return }
        try await importAssetsService.updateFiatAssets()
        debugLog("Updated fiat assets: on ramp \(config.versions.fiatOnRampAssets), off ramp \(config.versions.fiatOffRampAssets)")
    }

    private func updateSwapAssets(config: ConfigResponse) async throws {
        guard shouldUpdateSwapAssets(versions: config.versions) else { return }
        try await importAssetsService.updateSwapAssets()
        debugLog("Updated swap assets: \(config.versions.swapAssets)")
    }

    private func shouldUpdateFiatAssets(versions: ConfigVersions) -> Bool {
        versions.fiatOnRampAssets > preferences.fiatOnRampAssetsVersion ||
        versions.fiatOffRampAssets > preferences.fiatOffRampAssetsVersion
    }

    private func shouldUpdateSwapAssets(versions: ConfigVersions) -> Bool {
        versions.swapAssets > preferences.swapAssetsVersion
    }
}

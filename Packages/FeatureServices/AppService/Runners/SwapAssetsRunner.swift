// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import AssetsService

public struct SwapAssetsRunner: OnstartAsyncRunnable {
    private let importAssetsService: ImportAssetsService
    private let assetsService: AssetsService
    private let swappableChainsProvider: any SwappableChainsProvider
    private let preferences: Preferences

    public init(
        importAssetsService: ImportAssetsService,
        assetsService: AssetsService,
        swappableChainsProvider: any SwappableChainsProvider,
        preferences: Preferences
    ) {
        self.importAssetsService = importAssetsService
        self.assetsService = assetsService
        self.swappableChainsProvider = swappableChainsProvider
        self.preferences = preferences
    }

    public func run(config: ConfigResponse?) async throws {
        let chains = swappableChainsProvider.supportedChains()
        try assetsService.setSwappableAssets(for: chains)

        guard let versions = config?.versions, shouldUpdateFromAPI(versions: versions) else { return }
        try await importAssetsService.updateSwapAssets()
        debugLog("Updated swap assets: \(versions.swapAssets)")
    }

    private func shouldUpdateFromAPI(versions: ConfigVersions) -> Bool {
        versions.swapAssets > preferences.swapAssetsVersion
    }
}

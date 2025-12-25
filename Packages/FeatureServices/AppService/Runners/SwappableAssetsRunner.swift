// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import AssetsService

public struct SwappableAssetsRunner: OnstartAsyncRunnable {
    private let assetsService: AssetsService
    private let swappableChainsProvider: any SwappableChainsProvider

    public init(
        assetsService: AssetsService,
        swappableChainsProvider: any SwappableChainsProvider
    ) {
        self.assetsService = assetsService
        self.swappableChainsProvider = swappableChainsProvider
    }

    public func run(config: ConfigResponse?) async throws {
        let chains = swappableChainsProvider.supportedChains()
        try assetsService.setSwappableAssets(for: chains)
    }
}

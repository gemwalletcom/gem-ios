// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import AssetsService
import AssetsServiceTestKit
import Primitives

public extension SwappableAssetsRunner {
    static func mock(
        assetsService: AssetsService = .mock(),
        swappableChainsProvider: any SwappableChainsProvider = SwappableChainsProviderMock()
    ) -> SwappableAssetsRunner {
        SwappableAssetsRunner(
            assetsService: assetsService,
            swappableChainsProvider: swappableChainsProvider
        )
    }
}

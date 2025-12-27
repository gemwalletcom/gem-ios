// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import AssetsService
import AssetsServiceTestKit
import Preferences
import PreferencesTestKit

public extension SwapAssetsRunner {
    static func mock(
        assetsService: AssetsService = .mock(),
        swappableChainsProvider: any SwappableChainsProvider = SwappableChainsProviderMock(),
        preferences: Preferences = .mock()
    ) -> SwapAssetsRunner {
        SwapAssetsRunner(
            importAssetsService: ImportAssetsService.mock(
                assetsService: assetsService,
                preferences: preferences
            ),
            assetsService: assetsService,
            swappableChainsProvider: swappableChainsProvider,
            preferences: preferences
        )
    }
}

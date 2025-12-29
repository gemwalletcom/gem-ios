// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import GemAPI
import GemAPITestKit
import Primitives
import PrimitivesTestKit
import Preferences
import PreferencesTestKit
import AssetsService
import AssetsServiceTestKit

public extension AssetsUpdateRunner {
    static func mock(
        configService: any GemAPIConfigService = GemAPIConfigServiceMock(config: .mock()),
        importAssetsService: ImportAssetsService = .mock(),
        assetsService: AssetsService = .mock(),
        swappableChainsProvider: any SwappableChainsProvider = SwappableChainsProviderMock.mock(),
        preferences: Preferences = .mock()
    ) -> AssetsUpdateRunner {
        AssetsUpdateRunner(
            configService: configService,
            importAssetsService: importAssetsService,
            assetsService: assetsService,
            swappableChainsProvider: swappableChainsProvider,
            preferences: preferences
        )
    }
}

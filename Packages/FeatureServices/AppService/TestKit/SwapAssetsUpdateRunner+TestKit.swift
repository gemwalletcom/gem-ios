// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import AssetsService
import AssetsServiceTestKit
import Preferences
import PreferencesTestKit

public extension SwapAssetsUpdateRunner {
    static func mock(
        importAssetsService: ImportAssetsService = .mock(),
        preferences: Preferences = .mock()
    ) -> SwapAssetsUpdateRunner {
        SwapAssetsUpdateRunner(
            importAssetsService: importAssetsService,
            preferences: preferences
        )
    }
}

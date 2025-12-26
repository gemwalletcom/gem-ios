// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import AssetsService
import AssetsServiceTestKit
import Preferences
import PreferencesTestKit

public extension FiatAssetsUpdateRunner {
    static func mock(
        importAssetsService: ImportAssetsService = .mock(),
        preferences: Preferences = .mock()
    ) -> FiatAssetsUpdateRunner {
        FiatAssetsUpdateRunner(
            importAssetsService: importAssetsService,
            preferences: preferences
        )
    }
}

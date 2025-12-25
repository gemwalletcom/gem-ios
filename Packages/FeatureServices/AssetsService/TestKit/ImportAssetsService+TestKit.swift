// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Preferences
import PreferencesTestKit
import Store
import StoreTestKit

public extension ImportAssetsService {
    static func mock(
        assetsService: AssetsService = .mock(),
        assetStore: AssetStore = .mock(),
        preferences: Preferences = .mock()
    ) -> ImportAssetsService {
        ImportAssetsService(
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )
    }
}

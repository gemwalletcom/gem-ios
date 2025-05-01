// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Preferences
import PreferencesTestKit
import StoreTestKit
import AssetsServiceTestKit
import GemAPITestKit
import Primitives

@testable import AssetsService

struct ImportAssetsServiceTests {
    @Test
    func migrateAddsAssetsOnFirstRun() throws {
        let preferences = Preferences.mock()
        preferences.localAssetsVersion = 0

        let assetStore = AssetStoreMock()
        let assetsService = AssetsServiceMock(assetStore: assetStore)

        let service = ImportAssetsService(
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )

        try service.migrate()

        let assets = assetStore.addedAssets
        #expect(assets.isNotEmpty)

        for asset in assets {
            #expect(asset.properties.isBuyable == (asset.score.rank >= 40))
        }
    }

    @Test
    func updateFiatAssetsMarksAssetsAndUpdatesPreferences() async throws {
        let preferences = Preferences.mock()
        let assetStore = AssetStoreMock()
        let assetsService = AssetsServiceMock(assetStore: assetStore)
        let assetListService = GemAPIAssetsListServiceMock(
            buyableFiatAssetsResult: FiatAssets(version: 1, assetIds: []),
            sellableFiatAssetsResult: FiatAssets(version: 2, assetIds: [])
        )

        let service = ImportAssetsService(
            assetListService: assetListService,
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )

        try await service.updateFiatAssets()

        #expect(preferences.fiatOnRampAssetsVersion == 1)
        #expect(preferences.fiatOffRampAssetsVersion == 2)
    }

    @Test
    func updateSwapAssetsMarksAssetsAndUpdatesPreferences() async throws {
        let preferences = Preferences.mock()
        let assetStore = AssetStoreMock()
        let assetsService = AssetsServiceMock(assetStore: assetStore)
        let assetListService = GemAPIAssetsListServiceMock(swapAssetsResult: FiatAssets(version: 3, assetIds: []))

        let service = ImportAssetsService(
            assetListService: assetListService,
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )

        try await service.updateSwapAssets()

        #expect(preferences.swapAssetsVersion == 3)
    }
}

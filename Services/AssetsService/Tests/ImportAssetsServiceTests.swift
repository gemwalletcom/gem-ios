// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Preferences
import PreferencesTestKit
import StoreTestKit
import AssetsServiceTestKit
import GemAPITestKit
import Primitives
import Store

@testable import AssetsService

struct ImportAssetsServiceTests {
    @Test
    func migrateAddsAssetsOnFirstRun() async throws {
        let preferences = Preferences.mock()
        preferences.localAssetsVersion = 0

        let assetStore: AssetStore = .mock()
        let assetsService: AssetsService = .mock(assetStore: assetStore)

        let service = ImportAssetsService(
            assetsService: assetsService,
            assetStore: assetStore,
            preferences: preferences
        )

        try service.migrate()

        let assets = try assetStore.getBasicAssets()
        #expect(assets.isNotEmpty)

        for asset in assets {
            #expect(asset.properties.isBuyable == (asset.score.rank >= 40))
            
            let isStakeSupported = AssetConfiguration
                .allChains
                .first(where: { $0.asset.id == asset.asset.id })?
                .isStakeSupported ?? false
            
            #expect(asset.properties.isStakeable == isStakeSupported)
        }
    }

    @Test
    func updateFiatAssetsMarksAssetsAndUpdatesPreferences() async throws {
        let preferences = Preferences.mock()
        let assetListService = GemAPIAssetsListServiceMock(
            buyableFiatAssetsResult: FiatAssets(version: 1, assetIds: []),
            sellableFiatAssetsResult: FiatAssets(version: 2, assetIds: [])
        )

        let service = ImportAssetsService(
            assetListService: assetListService,
            assetsService: .mock(),
            assetStore: .mock(),
            preferences: preferences
        )

        try await service.updateFiatAssets()

        #expect(preferences.fiatOnRampAssetsVersion == 1)
        #expect(preferences.fiatOffRampAssetsVersion == 2)
    }

    @Test
    func updateSwapAssetsMarksAssetsAndUpdatesPreferences() async throws {
        let preferences = Preferences.mock()
        let assetListService = GemAPIAssetsListServiceMock(swapAssetsResult: FiatAssets(version: 3, assetIds: []))

        let service = ImportAssetsService(
            assetListService: assetListService,
            assetsService: .mock(),
            assetStore: .mock(),
            preferences: preferences
        )

        try await service.updateSwapAssets()

        #expect(preferences.swapAssetsVersion == 3)
    }
}

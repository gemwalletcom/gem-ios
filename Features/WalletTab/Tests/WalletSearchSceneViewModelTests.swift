// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Store
import PrimitivesTestKit
import PreferencesTestKit
import WalletTabTestKit
@testable import WalletTab

@MainActor
struct WalletSearchSceneViewModelTests {

    @Test
    func recentActivityTypes() {
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).recentsRequest.types == RecentActivityType.allCases)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).recentsRequest.types.contains(.perpetual) == false)
    }

    @Test
    func searchRequestInitialization() {
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).searchRequest.limit == 13)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).searchRequest.limit == 100)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).searchRequest.types == [.asset, .perpetual])
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).searchRequest.types == [.asset])
    }

    @Test
    func hasMoreAssets() {
        let model = WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true))

        model.searchResult = WalletSearchResult(assets: (0..<12).map { _ in .mock() }, perpetuals: [])
        #expect(model.hasMoreAssets == false)

        model.searchResult = WalletSearchResult(assets: (0..<13).map { _ in .mock() }, perpetuals: [])
        #expect(model.hasMoreAssets == true)
    }

    @Test
    func hasMorePerpetuals() {
        let model = WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true))

        model.searchResult = WalletSearchResult(assets: [], perpetuals: (0..<3).map { _ in .mock() })
        #expect(model.hasMorePerpetuals == false)

        model.searchResult = WalletSearchResult(assets: [], perpetuals: (0..<4).map { _ in .mock() })
        #expect(model.hasMorePerpetuals == true)
    }
}

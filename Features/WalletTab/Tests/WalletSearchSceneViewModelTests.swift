// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import PreferencesTestKit
import WalletTabTestKit

@testable import WalletTab
@testable import Store

@MainActor
struct WalletSearchSceneViewModelTests {

    @Test
    func recentActivityTypes() {
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).recentsQuery.request.types == RecentActivityType.allCases)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).recentsQuery.request.types.contains(.perpetual) == false)
    }

    @Test
    func searchRequestInitialization() {
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).searchQuery.request.limit == 13)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).searchQuery.request.limit == 100)
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true)).searchQuery.request.types == [.asset, .perpetual])
        #expect(WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: false)).searchQuery.request.types == [.asset])
    }

    @Test
    func hasMoreAssets() {
        let model = WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true))

        model.searchQuery.value = WalletSearchResult(assets: (0..<12).map { _ in .mock() }, perpetuals: [])
        #expect(model.hasMoreAssets == false)

        model.searchQuery.value = WalletSearchResult(assets: (0..<13).map { _ in .mock() }, perpetuals: [])
        #expect(model.hasMoreAssets == true)
    }

    @Test
    func hasMorePerpetuals() {
        let model = WalletSearchSceneViewModel.mock(preferences: .mock(isPerpetualEnabled: true))

        model.searchQuery.value = WalletSearchResult(assets: [], perpetuals: (0..<3).map { _ in .mock() })
        #expect(model.hasMorePerpetuals == false)

        model.searchQuery.value = WalletSearchResult(assets: [], perpetuals: (0..<4).map { _ in .mock() })
        #expect(model.hasMorePerpetuals == true)
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import AssetsTestKit

@testable import Assets

@MainActor
struct SelectAssetViewModelTests {

    @Test
    func showEmpty() {
        #expect(SelectAssetViewModel.mock(assets: []).showEmpty == true)
        #expect(SelectAssetViewModel.mock(assets: [AssetData.mock(metadata: .mock(isPinned: true))]).showEmpty == false)
        #expect(SelectAssetViewModel.mock(assets: [AssetData.mock(metadata: .mock(isPinned: false))]).showEmpty == false)
    }

    @Test
    func showLoading() {
        let pinnedAsset = AssetData.mock(metadata: .mock(isPinned: true))
        #expect(SelectAssetViewModel.mock(assets: [], state: .loading).showLoading == true)
        #expect(SelectAssetViewModel.mock(assets: [pinnedAsset], state: .loading).showLoading == false)
    }
}

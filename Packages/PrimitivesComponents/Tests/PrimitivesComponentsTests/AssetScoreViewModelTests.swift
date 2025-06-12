// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesComponents

struct AssetScoreViewModelTests {

    @Test
    func testWarning() {
        #expect(AssetScoreViewModel(score: 0).hasWarning)
        #expect(AssetScoreViewModel(score: 5).hasWarning)
        #expect(AssetScoreViewModel(score: 6).hasWarning)
        #expect(AssetScoreViewModel(score: 15).hasWarning)
        #expect(!AssetScoreViewModel(score: 16).hasWarning)
    }

    @Test
    func testStatus() {
        #expect(AssetScoreViewModel(score: 3).status == "Suspicious")
        #expect(AssetScoreViewModel(score: 10).status == "Unverified")
        #expect(AssetScoreViewModel(score: 20).status.isEmpty)
    }

    @Test
    func testAssetImage() {
        #expect(AssetScoreViewModel(score: 2).assetImage != nil)
        #expect(AssetScoreViewModel(score: 12).assetImage != nil)
        #expect(AssetScoreViewModel(score: 30).assetImage == nil)
    }
}

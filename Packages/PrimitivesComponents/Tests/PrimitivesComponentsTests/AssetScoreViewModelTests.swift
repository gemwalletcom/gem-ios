// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesComponents

struct AssetScoreViewModelTests {

    @Test
    func testWarning() {
        #expect(!AssetScoreTypeViewModel(score: 0).hasWarning)
        #expect(!AssetScoreTypeViewModel(score: 5).hasWarning)
        #expect(AssetScoreTypeViewModel(score: 6).hasWarning)
        #expect(AssetScoreTypeViewModel(score: 15).hasWarning)
        #expect(!AssetScoreTypeViewModel(score: 16).hasWarning)
    }

    @Test
    func testStatus() {
        #expect(AssetScoreTypeViewModel(score: 3).status == "Suspicious")
        #expect(AssetScoreTypeViewModel(score: 10).status == "Unverified")
        #expect(AssetScoreTypeViewModel(score: 20).status.isEmpty)
    }
    
    @Test
    func testShouldShowBanner() {
        #expect(AssetScoreTypeViewModel(score: 0).shouldShowBanner)
        #expect(!AssetScoreTypeViewModel(score: 30).shouldShowBanner)
        #expect(!AssetScoreTypeViewModel(score: 50).shouldShowBanner)
        #expect(!AssetScoreTypeViewModel(score: 100).shouldShowBanner)
    }
}

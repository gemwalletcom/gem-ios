// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit

@testable import Swap

struct SwapPairSelectorViewModelTests {
    @Test
    func testDefaultPairNative() {
        let native = Asset.mockEthereum()
        let result = SwapPairSelectorViewModel.defaultSwapPair(for: native)

        #expect(result.fromAssetId == native.chain.assetId)
        #expect(result.toAssetId == nil)
    }

    @Test
    func testDefaultPairToken() {
        let token = Asset.mockEthereumUSDT()
        let result = SwapPairSelectorViewModel.defaultSwapPair(for: token)

        #expect(result.fromAssetId == token.id)
        #expect(result.toAssetId == token.chain.assetId)
    }
}

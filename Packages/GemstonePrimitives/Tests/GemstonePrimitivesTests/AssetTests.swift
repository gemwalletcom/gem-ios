// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import GemstonePrimitives

final class AssetTests {
    let nativeAsset = Asset(.ethereum)
    let tokenAsset = Asset(id: AssetId(chain: .ethereum, tokenId: "0x123"), name: "", symbol: "", decimals: 18, type: .erc20)

    @Test
    func testAssetFee() {
        #expect(nativeAsset.feeAsset == nativeAsset)
        #expect(tokenAsset.feeAsset != tokenAsset)
        #expect(tokenAsset.feeAsset == nativeAsset)
    }
}

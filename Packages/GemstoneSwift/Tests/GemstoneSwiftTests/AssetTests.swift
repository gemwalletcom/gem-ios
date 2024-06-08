// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstoneSwift
import Primitives

final class AssetTests: XCTestCase {
    
    let nativeAsset = Asset(.ethereum)
    let tokenAsset = Asset(id: AssetId(chain: .ethereum, tokenId: "0x123"), name: "", symbol: "", decimals: 18, type: .erc20)
    
    func testAssetFee() {
        XCTAssertEqual(nativeAsset.feeAsset, nativeAsset)
        XCTAssertNotEqual(tokenAsset.feeAsset, tokenAsset)
        XCTAssertEqual(tokenAsset.feeAsset, nativeAsset)
    }
}

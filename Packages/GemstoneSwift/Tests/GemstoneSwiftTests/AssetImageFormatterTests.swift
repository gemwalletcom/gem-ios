// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstoneSwift
import Primitives

final class AssetImageFormatterTests: XCTestCase {

    func testGetURL() {
        let formatter = AssetImageFormatter()
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: .none)).absoluteString,
            URL(string: "https://assets.gemwallet.com/blockchains/ethereum/logo.png")?.absoluteString
        )
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")).absoluteString,
            URL(string: "https://assets.gemwallet.com/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png")?.absoluteString
        )
    }
}

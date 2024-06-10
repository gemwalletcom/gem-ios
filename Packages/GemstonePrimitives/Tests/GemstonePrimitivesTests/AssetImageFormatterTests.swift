// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstonePrimitives
import Primitives

final class AssetImageFormatterTests: XCTestCase {

    func testGetURL() {
        let formatter = AssetImageFormatter()
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: .none))?.absoluteString,
            URL(string: "https://assets.gemwallet.com/blockchains/ethereum/logo.png")?.absoluteString
        )
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"))?.absoluteString,
            URL(string: "https://assets.gemwallet.com/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png")?.absoluteString
        )
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ton, tokenId: "ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT"))?.absoluteString,
            URL(string: "https://assets.gemwallet.com/blockchains/ton/assets/ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT/logo.png")?.absoluteString
        )
    }
}

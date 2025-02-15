// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Primitives

struct URLParserTests {

    @Test func testAssetUrl() async throws {
        let chainAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/bitcoin")!)
        
        #expect(chainAction == URLAction.asset(AssetId(chain: .bitcoin, tokenId: .none)))
        
        let tokenAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/ethereum/0xdAC17F958D2ee523a2206206994597C13D831ec7")!)
        
        #expect(tokenAction == URLAction.asset(AssetId(chain: .bitcoin, tokenId: .none)) )
    }
}

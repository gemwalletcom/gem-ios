// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Primitives

struct URLParserTests {

    @Test func testAssetUrl() async throws {
        let chainAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/bitcoin")!)
        
        #expect(chainAction == URLAction.asset(AssetId(chain: .bitcoin, tokenId: .none)))
        
        let tokenAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/ethereum/0xdAC17F958D2ee523a2206206994597C13D831ec7")!)
        
        #expect(tokenAction == URLAction.asset(AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")) )
    }

    @Test func testWCUrl() async throws {
        let url = "gem://wc?sessionTopic=64a4f0817e3dd003cbe23202fb6ffaa16d38074de84762a5797e6092b2250a27"

        let action = try URLParser.from(url: URL(string: url)!)

        #expect(action == .walletConnectSession("64a4f0817e3dd003cbe23202fb6ffaa16d38074de84762a5797e6092b2250a27"))
    }
}

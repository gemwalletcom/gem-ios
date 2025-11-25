// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@testable import Primitives
import Testing

struct URLParserTests {
    @Test
    func assetUrl() async throws {
        let chainAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/bitcoin")!)

        #expect(chainAction == URLAction.asset(AssetId(chain: .bitcoin, tokenId: .none)))

        let tokenAction = try URLParser.from(url: URL(string: "https://gemwallet.com/tokens/ethereum/0xdAC17F958D2ee523a2206206994597C13D831ec7")!)

        #expect(tokenAction == URLAction.asset(AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")))
    }

    @Test
    func swapUrl() async throws {
        let swapFromOnly = try URLParser.from(url: URL(string: "https://gemwallet.com/swap/ethereum")!)

        #expect(swapFromOnly == .swap(AssetId(chain: .ethereum, tokenId: nil), nil))

        let swapFromTo = try URLParser.from(url: URL(string: "https://gemwallet.com/swap/ethereum/ethereum_0xdAC17F958D2ee523a2206206994597C13D831ec7")!)

        #expect(swapFromTo == .swap(
            AssetId(chain: .ethereum, tokenId: nil),
            AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")
        ))
    }

    @Test func walletConnectSessionTopicUrl() async throws {
        let url = "gem://wc?sessionTopic=64a4f0817e3dd003cbe23202fb6ffaa16d38074de84762a5797e6092b2250a27"

        let action = try URLParser.from(url: URL(string: url)!)

        #expect(action == .walletConnectSession("64a4f0817e3dd003cbe23202fb6ffaa16d38074de84762a5797e6092b2250a27"))
    }

    @Test
    func perpetualsUrl() async throws {
        let perpetualsAction = try URLParser.from(url: URL(string: "https://gemwallet.com/perpetuals")!)

        #expect(perpetualsAction == .perpetuals)
    }
}

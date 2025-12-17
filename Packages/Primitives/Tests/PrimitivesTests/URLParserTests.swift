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

    @Test
    func gemUrlWithoutAction() async throws {
        #expect(try URLParser.from(url: URL(string: "gem://")!) == .none)
        #expect(try URLParser.from(url: URL(string: "gem://invalidpath")!) == .none)
    }

    @Test
    func rewardsUrl() async throws {
        #expect(try URLParser.from(url: URL(string: "https://gemwallet.com/join?code=gemcoder")!) == .rewards(code: "gemcoder"))
        #expect(try URLParser.from(url: URL(string: "https://gemwallet.com/rewards?code=gemcoder")!) == .rewards(code: "gemcoder"))
    }

    @Test
    func buyUrl() async throws {
        let buyChain = try URLParser.from(url: URL(string: "https://gemwallet.com/buy/bitcoin")!)
        #expect(buyChain == .buy(AssetId(chain: .bitcoin, tokenId: nil), amount: nil))

        let buyToken = try URLParser.from(url: URL(string: "https://gemwallet.com/buy/ethereum_0xdAC17F958D2ee523a2206206994597C13D831ec7")!)
        #expect(buyToken == .buy(AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"), amount: nil))

        let buyWithAmount = try URLParser.from(url: URL(string: "https://gemwallet.com/buy/bitcoin?amount=100")!)
        #expect(buyWithAmount == .buy(AssetId(chain: .bitcoin, tokenId: nil), amount: 100))

        let buyTokenWithAmount = try URLParser.from(url: URL(string: "https://gemwallet.com/buy/ethereum_0xdAC17F958D2ee523a2206206994597C13D831ec7?amount=50")!)
        #expect(buyTokenWithAmount == .buy(AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"), amount: 50))
    }

    @Test
    func sellUrl() async throws {
        let sellChain = try URLParser.from(url: URL(string: "https://gemwallet.com/sell/bitcoin")!)
        #expect(sellChain == .sell(AssetId(chain: .bitcoin, tokenId: nil), amount: nil))

        let sellWithAmount = try URLParser.from(url: URL(string: "https://gemwallet.com/sell/ethereum?amount=200")!)
        #expect(sellWithAmount == .sell(AssetId(chain: .ethereum, tokenId: nil), amount: 200))
    }

    @Test
    func setPriceAlertUrl() async throws {
        let alertWithPrice = try URLParser.from(url: URL(string: "https://gemwallet.com/setPriceAlert/bitcoin?price=50000")!)
        #expect(alertWithPrice == .setPriceAlert(AssetId(chain: .bitcoin, tokenId: nil), price: 50000))

        let alertTokenWithPrice = try URLParser.from(url: URL(string: "https://gemwallet.com/setPriceAlert/ethereum_0xdAC17F958D2ee523a2206206994597C13D831ec7?price=1.5")!)
        #expect(alertTokenWithPrice == .setPriceAlert(AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"), price: 1.5))
    }

    @Test
    func setPriceAlertUrlWithoutPrice() async throws {
        #expect(throws: URLParserError.self) {
            try URLParser.from(url: URL(string: "https://gemwallet.com/setPriceAlert/bitcoin")!)
        }
    }
}

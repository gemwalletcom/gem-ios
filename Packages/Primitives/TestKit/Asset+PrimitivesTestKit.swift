// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Asset {
    static func mock(
        id: AssetId = .mock(),
        name: String = "Bitcoin",
        symbol: String = "BTC",
        decimals: Int32 = 8,
        type: AssetType = .native
    ) -> Asset {
        Asset(
            id: id,
            name: name,
            symbol: symbol,
            decimals: decimals,
            type: type
        )
    }
    
    static func mockEthereum() -> Asset {
        .mock(
            id: AssetId(chain: .ethereum, tokenId: .none),
            name: "Ethereum",
            symbol: "ETH",
            decimals: 18,
            type: .native
        )
    }
    
    static func mockBNB() -> Asset {
        .mock(
            id: AssetId(chain: .smartChain, tokenId: .none),
            name: "BNB",
            symbol: "BNB",
            decimals: 18,
            type: .native
        )
    }
    
    static func mockEthereumUSDT() -> Asset {
        .mock(
            id: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"),
            name: "Tether",
            symbol: "USDT",
            decimals: 6,
            type: .erc20
        )
    }
}

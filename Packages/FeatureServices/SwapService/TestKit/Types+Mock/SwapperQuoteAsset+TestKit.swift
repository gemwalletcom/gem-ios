// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperQuoteAsset

extension SwapperQuoteAsset {
    static func mock() -> SwapperQuoteAsset {
        SwapperQuoteAsset(
            id: "ethereum:0x0000000000000000000000000000000000000000",
            symbol: "ETH",
            decimals: 18
        )
    }
    
    static func mockUSDT() -> SwapperQuoteAsset {
        SwapperQuoteAsset(
            id: "ethereum:0xdac17f958d2ee523a2206206994597c13d831ec7",
            symbol: "USDT",
            decimals: 6
        )
    }
} 

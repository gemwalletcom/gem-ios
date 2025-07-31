// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperQuoteRequest
import struct Gemstone.SwapperQuoteAsset
import enum Gemstone.SwapperMode
import struct Gemstone.SwapperOptions

extension SwapperQuoteRequest {
    static func mock() -> SwapperQuoteRequest {
        SwapperQuoteRequest(
            fromAsset: .mock(),
            toAsset: .mockUSDT(),
            walletAddress: "0x",
            destinationAddress: "0x",
            value: "1000000000000000000",
            mode: .exactIn,
            options: .mock()
        )
    }
} 

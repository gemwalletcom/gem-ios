// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapQuoteRequest
import struct Gemstone.GemQuoteAsset
import enum Gemstone.GemSwapMode
import struct Gemstone.GemSwapOptions

extension SwapQuoteRequest {
    static func mock() -> SwapQuoteRequest {
        SwapQuoteRequest(
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

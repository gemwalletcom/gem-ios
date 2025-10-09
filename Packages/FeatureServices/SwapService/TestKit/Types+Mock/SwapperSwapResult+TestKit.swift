// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperSwapResult
import enum Gemstone.SwapperSwapStatus
import typealias Gemstone.Chain

public extension SwapperSwapResult {
    static func mock(
        status: SwapperSwapStatus = .completed,
        fromChain: Chain = "ethereum",
        fromTxHash: String = "0x123",
        toChain: Chain = "ethereum", 
        toTxHash: String = "0x456"
    ) -> SwapperSwapResult {
        SwapperSwapResult(
            status: status,
            fromChain: fromChain,
            fromTxHash: fromTxHash,
            toChain: toChain,
            toTxHash: toTxHash
        )
    }
}
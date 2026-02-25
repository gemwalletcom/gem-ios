// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperSwapResult
import struct Gemstone.SwapperTransactionSwapMetadata
import enum Gemstone.SwapperSwapStatus

public extension SwapperSwapResult {
    static func mock(
        status: SwapperSwapStatus = .completed,
        metadata: SwapperTransactionSwapMetadata? = nil
    ) -> SwapperSwapResult {
        SwapperSwapResult(
            status: status,
            metadata: metadata
        )
    }
}

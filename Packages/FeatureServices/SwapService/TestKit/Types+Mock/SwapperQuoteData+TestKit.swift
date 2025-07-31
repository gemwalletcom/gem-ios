// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperQuoteData

public extension SwapperQuoteData {
    static func mock() -> SwapperQuoteData {
        SwapperQuoteData(
            to: "0x",
            value: "0",
            data: "0x",
            approval: .mock(),
            gasLimit: "210000"
        )
    }
}

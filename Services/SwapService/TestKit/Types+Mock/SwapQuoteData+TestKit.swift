// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapQuoteData

public extension SwapQuoteData {
    static func mock() -> SwapQuoteData {
        SwapQuoteData(
            to: "0x",
            value: "0",
            data: "0x",
            approval: .mock(),
            gasLimit: "210000"
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.GemSwapQuoteData

public extension GemSwapQuoteData {
    static func mock() -> GemSwapQuoteData {
        GemSwapQuoteData(
            to: "0x",
            value: "0",
            data: "0x",
            approval: .mock(),
            gasLimit: "210000"
        )
    }
}

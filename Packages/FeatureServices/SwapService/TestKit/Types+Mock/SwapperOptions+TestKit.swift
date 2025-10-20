// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperOptions
import struct Gemstone.SwapperSlippage
import enum Gemstone.SwapperSlippageMode

extension SwapperOptions {
    static func mock() -> SwapperOptions {
        SwapperOptions(
            slippage: SwapperSlippage(
                bps: 50,
                mode: .auto
            ),
            fee: nil,
            preferredProviders: [],
            useMaxAmount: false
        )
    }
} 

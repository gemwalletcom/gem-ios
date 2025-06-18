// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapOptions
import struct Gemstone.GemSlippage
import enum Gemstone.GemSlippageMode

extension GemSwapOptions {
    static func mock() -> GemSwapOptions {
        GemSwapOptions(
            slippage: GemSlippage(
                bps: 50,
                mode: .auto
            ),
            fee: nil,
            preferredProviders: []
        )
    }
} 

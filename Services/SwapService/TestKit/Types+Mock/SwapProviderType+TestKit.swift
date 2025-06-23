// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapProviderType
import enum Gemstone.GemSwapProvider

public extension SwapProviderType {
    static func mock() -> SwapProviderType {
        SwapProviderType(
            id: .pancakeswapV3,
            name: "PancakeSwap",
            protocol: "v3",
            protocolId: "pancakeswap_v3"
        )
    }
} 

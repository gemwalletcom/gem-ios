// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperProviderType
import enum Gemstone.SwapperProvider

public extension SwapperProviderType {
    static func mock() -> SwapperProviderType {
        SwapperProviderType(
            id: .pancakeswapV3,
            name: "PancakeSwap",
            protocol: "v3",
            protocolId: "pancakeswap_v3",
            mode: .onChain
        )
    }
} 

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.SwapperProvider
import struct Gemstone.SwapperProviderType

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

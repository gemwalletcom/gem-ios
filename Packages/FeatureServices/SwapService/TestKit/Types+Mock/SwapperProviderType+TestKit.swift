// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.SwapperProvider
import struct Gemstone.SwapperProviderType

public extension SwapperProviderType {
    static func mock(id: SwapperProvider = .pancakeswapV3) -> SwapperProviderType {
        SwapperProviderType(
            id: id,
            name: "\(id)",
            protocol: "v3",
            protocolId: "\(id)_v3",
            mode: .onChain
        )
    }
}

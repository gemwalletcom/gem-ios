// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapProviderData {
    public static func mock(
        provider: SwapProvider = .uniswapV4,
        name: String = "Uniswap",
        protocolName: String = "Uniswap v3"
    ) -> SwapProviderData {
        SwapProviderData(
            provider: .mayan,
            name: name,
            protocolName: protocolName
        )
    }
}

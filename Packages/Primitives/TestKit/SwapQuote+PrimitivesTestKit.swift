// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapQuote {
    public static func mock(
    ) -> SwapQuote {
        SwapQuote(fromValue: "", toValue: "", provider: .uniswapV4, walletAddress: "", slippageBps: 50)
    }
}

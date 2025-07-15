// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapQuote {
    public static func mock(
        providerData: SwapProviderData = .mock(),
        etaInSeconds: UInt32 = 123
    ) -> SwapQuote {
        SwapQuote(
            fromValue: "",
            toValue: "",
            providerData: providerData,
            walletAddress: "",
            slippageBps: 50,
            etaInSeconds: 123
        )
    }
}

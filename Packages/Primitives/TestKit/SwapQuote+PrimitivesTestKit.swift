// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension SwapQuote {
    public static func mock(
        fromValue: String = "1000000000000000000",
        toValue: String = "2000000000000000000",
        providerData: SwapProviderData = .mock(),
        walletAddress: String = "0x0000000000000000000000000000000000000000",
        etaInSeconds: UInt32 = 123,
        useMaxAmount: Bool = false
    ) -> SwapQuote {
        SwapQuote(
            fromAddress: walletAddress,
            fromValue: fromValue,
            toAddress: walletAddress,
            toValue: toValue,
            providerData: providerData,
            slippageBps: 50,
            etaInSeconds: etaInSeconds,
            useMaxAmount: useMaxAmount
        )
    }
}

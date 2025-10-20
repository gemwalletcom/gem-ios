// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapQuote
import Primitives

public extension Gemstone.GemSwapQuote {
    func map() throws -> Primitives.SwapQuote {
        try Primitives.SwapQuote(
            fromAddress: fromAddress,
            fromValue: fromValue,
            toAddress: toAddress,
            toValue: toValue,
            providerData: providerData.map(),
            slippageBps: slippageBps,
            etaInSeconds: etaInSeconds,
            useMaxAmount: useMaxAmount
        )
    }
}

extension Primitives.SwapQuote {
    func map() -> Gemstone.GemSwapQuote {
        Gemstone.GemSwapQuote(
            fromAddress: fromAddress,
            fromValue: fromValue,
            toAddress: toAddress,
            toValue: toValue,
            providerData: providerData.map(),
            slippageBps: slippageBps,
            etaInSeconds: etaInSeconds,
            useMaxAmount: useMaxAmount
        )
    }
}

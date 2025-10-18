// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemApprovalData
import struct Gemstone.GemSwapData
import struct Gemstone.GemSwapProviderData
import struct Gemstone.GemSwapQuote
import struct Gemstone.GemSwapQuoteData
import Primitives

public extension Gemstone.GemSwapData {
    func map() throws -> Primitives.SwapData {
        try Primitives.SwapData(
            quote: quote.map(),
            data: data.map()
        )
    }
}

extension Primitives.SwapData {
    func map() -> Gemstone.GemSwapData {
        Gemstone.GemSwapData(
            quote: quote.map(),
            data: data.map()
        )
    }
}

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

public extension Gemstone.GemSwapQuoteData {
    func map() throws -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            to: to,
            value: value,
            data: data,
            memo: memo,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension Primitives.SwapQuoteData {
    func map() -> Gemstone.GemSwapQuoteData {
        Gemstone.GemSwapQuoteData(
            to: to,
            value: value,
            data: data,
            memo: memo,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

public extension Gemstone.GemSwapProviderData {
    func map() throws -> Primitives.SwapProviderData {
        return Primitives.SwapProviderData(
            provider: provider.asPrimitives(),
            name: name,
            protocolName: protocolName
        )
    }
}

extension Primitives.SwapProviderData {
    func map() -> Gemstone.GemSwapProviderData {
        Gemstone.GemSwapProviderData(
            provider: provider.map(),
            name: name,
            protocolName: protocolName
        )
    }
}

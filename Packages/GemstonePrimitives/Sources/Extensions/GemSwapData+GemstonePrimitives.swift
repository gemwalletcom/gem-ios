// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import struct Gemstone.GemSwapData
import struct Gemstone.GemSwapQuote
import struct Gemstone.GemSwapQuoteData
import struct Gemstone.GemSwapProviderData
import struct Gemstone.GemApprovalData

public extension Gemstone.GemSwapData {
    func map() throws -> Primitives.SwapData {
        Primitives.SwapData(
            quote: try quote.map(),
            data: try data.map()
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
        Primitives.SwapQuote(
            fromValue: fromValue,
            toValue: toValue,
            providerData: try providerData.map(),
            walletAddress: walletAddress,
            slippageBps: slippageBps,
            etaInSeconds: etaInSeconds
        )
    }
}

extension Primitives.SwapQuote {
    func map() -> Gemstone.GemSwapQuote {
        Gemstone.GemSwapQuote(
            fromValue: fromValue,
            toValue: toValue,
            providerData: providerData.map(),
            walletAddress: walletAddress,
            slippageBps: slippageBps,
            etaInSeconds: etaInSeconds
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
        guard let swapProvider = SwapProvider(rawValue: provider) else {
            throw AnyError("Invalid swap provider: \(provider)")
        }
        return Primitives.SwapProviderData(
            provider: swapProvider,
            name: name,
            protocolName: protocolName
        )
    }
}

extension Primitives.SwapProviderData {
    func map() -> Gemstone.GemSwapProviderData {
        Gemstone.GemSwapProviderData(
            provider: provider.rawValue,
            name: name,
            protocolName: protocolName
        )
    }
}

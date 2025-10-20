// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperProviderType

public extension Gemstone.SwapperQuote {
    func map() -> Primitives.SwapQuote {
        Primitives.SwapQuote(
            fromAddress: request.walletAddress,
            fromValue: fromValue,
            toAddress: request.destinationAddress,
            toValue: toValue,
            providerData: data.provider.asPrimitive,
            slippageBps: data.slippageBps,
            etaInSeconds: self.etaInSeconds,
            useMaxAmount: request.options.useMaxAmount
        )
    }
    
    var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }

    var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}

extension Gemstone.SwapperProviderType {
    var asPrimitive: Primitives.SwapProviderData {
        Primitives.SwapProviderData(
            provider: SwapProvider(rawValue: protocolId)!,
            name: self.name,
            protocolName: self.protocol
        )
    }
}

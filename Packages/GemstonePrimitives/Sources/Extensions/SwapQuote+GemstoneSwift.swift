// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import struct Gemstone.SwapQuote
import struct Gemstone.SwapProviderType

public extension SwapQuote {
    var asPrimitive: Primitives.SwapQuote {
        Primitives.SwapQuote(
            fromValue: fromValue,
            toValue: toValue,
            providerData: data.provider.asPrimitive,
            walletAddress: request.walletAddress,
            slippageBps: data.slippageBps,
            etaInSeconds: self.etaInSeconds
        )
    }
    
    var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }

    var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}

extension SwapProviderType {
    var asPrimitive: Primitives.SwapProviderData {
        Primitives.SwapProviderData(
            provider: SwapProvider(rawValue: protocolId)!,
            name: self.name,
            protocolName: self.protocol
        )
    }
}

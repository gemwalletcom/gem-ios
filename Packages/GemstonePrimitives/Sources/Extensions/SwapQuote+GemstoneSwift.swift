// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import struct Gemstone.SwapperQuote

public extension SwapperQuote {
    var asPrimitive: Primitives.SwapQuote {
        Primitives.SwapQuote(
            fromValue: fromValue,
            toValue: toValue,
            provider: SwapProvider(rawValue: data.provider.protocolId)!,
            walletAddress: request.walletAddress,
            slippageBps: data.slippageBps
        )
    }
    
    var toValueBigInt: BigInt {
        (try? BigInt.from(string: toValue)) ?? .zero
    }

    var fromValueBigInt: BigInt {
        (try? BigInt.from(string: fromValue)) ?? .zero
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperProviderType

public extension Gemstone.SwapperQuote {
    func map() throws -> Primitives.SwapQuote {
        Primitives.SwapQuote(
            fromAddress: request.walletAddress,
            fromValue: fromValue,
            toAddress: request.destinationAddress,
            toValue: toValue,
            providerData: try data.provider.map(),
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
    func map() throws -> Primitives.SwapProviderData {
        Primitives.SwapProviderData(
            provider: try id.map(),
            name: self.name,
            protocolName: self.protocol
        )
    }
}

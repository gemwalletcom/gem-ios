// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData

public enum SwapAction: Sendable {
    case swap(SwapQuote, SwapQuoteData)
    case approval(spender: String, allowance: BigInt)
}

extension SwapAction: Hashable {}

public struct SwapApproval: Equatable {
    public let allowance: BigInt
    public let spender: String
}
extension SwapApproval: Hashable {}

public struct SwapData: Equatable, Sendable {
    public let quote: SwapQuoteData
    
    public init(
        quote: SwapQuoteData
    ) {
        self.quote = quote
    }
}

extension SwapData {
    public var hexData: Data? {
        return Data(fromHex: quote.data)
    }
}

extension SwapData: Hashable {}

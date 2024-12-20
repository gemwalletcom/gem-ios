// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import struct Gemstone.SwapQuote
import enum Gemstone.SwapProvider
import struct Gemstone.SwapQuoteData

// Add SwapProvider to Approval type
public enum SwapAction: Sendable {
    case swap(SwapQuote, SwapQuoteData)
    case approval(SwapQuote, spender: String, allowance: BigInt)
}

extension SwapAction {
    public var provider: SwapProvider {
        switch self {
        case .swap(let quote, _): quote.data.provider
        case .approval(let quote, _, _): quote.data.provider
        }
    }
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

// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct FiatInput: Sendable {
    public let type: FiatQuoteType

    public var amount: Double
    public var maxAmount: Double
    public var quote: FiatQuote?

    public init(type: FiatQuoteType, amount: Double, maxAmount: Double, quote: FiatQuote? = nil) {
        self.type = type
        self.amount = amount
        self.quote = quote
        self.maxAmount = maxAmount
    }
}

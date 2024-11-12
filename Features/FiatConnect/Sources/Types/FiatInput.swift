// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct FiatInput: Sendable {
    public let type: FiatTransactionType

    public var amount: Double
    public var quote: FiatQuote?

    public init(
        type: FiatTransactionType,
        amount: Double,
        quote: FiatQuote? = nil
    ) {
        self.type = type
        self.amount = amount
        self.quote = quote
    }
}

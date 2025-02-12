// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct FiatInput: Sendable {
    public var type: FiatTransactionType

    public var buyAmount: Double
    public var sellAmount: Double

    public var quote: FiatQuote?

    public init(
        type: FiatTransactionType,
        buyAmount: Double = .zero,
        sellAmount: Double = .zero
    ) {
        self.type = type
        self.buyAmount = buyAmount
        self.sellAmount = sellAmount
    }

    public var amount: Double {
        get {
            switch type {
            case .buy: buyAmount
            case .sell: sellAmount
            }
        } set {
            switch type {
            case .buy: buyAmount = newValue
            case .sell: sellAmount = newValue
            }
        }
    }
}

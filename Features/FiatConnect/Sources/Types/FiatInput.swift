// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import Components

public struct FiatInput: Sendable, Equatable {
    public var type: FiatQuoteType

    private var buyAmount: Double
    private var sellAmount: Double

    private var sellQuote: FiatQuote?
    private var buyQuote: FiatQuote?

    public init(
        type: FiatQuoteType,
        buyAmount: Double = .zero,
        sellAmount: Double = .zero
    ) {
        self.type = type
        self.buyAmount = buyAmount
        self.sellAmount = sellAmount
    }

    public var quote: FiatQuote? {
        get {
            switch type {
            case .buy: buyQuote
            case .sell: sellQuote
            }
        } set {
            switch type {
            case .buy: buyQuote = newValue
            case .sell: sellQuote = newValue
            }
        }
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

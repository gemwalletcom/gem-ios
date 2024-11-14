// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct FiatProvidersViewModel {
    private let formatter: CurrencyFormatter
    private var asset: Asset
    private var quotes: [FiatQuote]

    public let type: FiatTransactionType
    public var selectQuote: ((FiatQuote) -> Void)?

    public init(
        type: FiatTransactionType,
        asset: Asset,
        quotes: [FiatQuote],
        selectQuote: ((FiatQuote) -> Void)? = nil,
        formatter: CurrencyFormatter
    ) {
        self.type = type
        self.asset = asset
        self.quotes = quotes
        self.selectQuote = selectQuote
        self.formatter = formatter
    }

    public var quotesViewModel: [FiatQuoteViewModel] {
        quotes.map {
            FiatQuoteViewModel(
                asset: asset,
                quote: $0,
                formatter: formatter
            )
        }
    }
}

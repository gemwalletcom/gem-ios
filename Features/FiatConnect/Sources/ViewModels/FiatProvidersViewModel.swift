// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct FiatProvidersViewModel {
    private var asset: Asset
    private var quotes: [FiatQuote]
    public var selectQuote: ((FiatQuote) -> Void)?
    private let formatter: CurrencyFormatter

    public init(
        asset: Asset,
        quotes: [FiatQuote],
        selectQuote: ((FiatQuote) -> Void)? = nil,
        formatter: CurrencyFormatter
    ) {
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

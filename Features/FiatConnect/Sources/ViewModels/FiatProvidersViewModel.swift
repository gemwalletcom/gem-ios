// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct FiatProvidersViewModel: Sendable, Hashable {
    private let formatter: CurrencyFormatter
    private var asset: Asset
    private var quotes: [FiatQuote]

    public let type: FiatTransactionType

    public init(
        type: FiatTransactionType,
        asset: Asset,
        quotes: [FiatQuote],
        formatter: CurrencyFormatter
    ) {
        self.type = type
        self.asset = asset
        self.quotes = quotes
        self.formatter = formatter
    }

    public var title: String { Localized.Buy.Providers.title }

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

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct FiatProvidersViewModel: Sendable {
    public typealias SelectQuote = (@MainActor @Sendable (FiatQuote) -> Void)
    private let formatter: CurrencyFormatter
    private var asset: Asset
    private var quotes: [FiatQuote]

    public let type: FiatTransactionType
    public let onSelectQuote: SelectQuote?

    public init(
        type: FiatTransactionType,
        asset: Asset,
        quotes: [FiatQuote],
        formatter: CurrencyFormatter,
        onSelectQuote: SelectQuote? = nil
    ) {
        self.type = type
        self.asset = asset
        self.quotes = quotes
        self.formatter = formatter
        self.onSelectQuote = onSelectQuote
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

// MARK: - Hashable

extension FiatProvidersViewModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(asset)
        hasher.combine(quotes)
        hasher.combine(formatter)
    }

    public static func == (lhs: FiatProvidersViewModel, rhs: FiatProvidersViewModel) -> Bool {
        lhs.type == rhs.type
        && lhs.asset == rhs.asset
        && lhs.quotes == rhs.quotes
        && lhs.formatter == rhs.formatter
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components

public struct FiatQuoteViewModel {
    let quote: FiatQuote

    private let asset: Asset
    private let formatter: CurrencyFormatter

    public init(
        asset: Asset,
        quote: FiatQuote,
        formatter: CurrencyFormatter
    ) {
        self.asset = asset
        self.quote = quote
        self.formatter = formatter
    }

    public var title: String {
        quote.provider.name
    }

    public var amountText: String {
        switch quote.type {
        case .buy: "\(amount)\(asset.symbol)"
        case .sell: "\(amount)$"
        }
    }

    public var rateText: String {
        let amount = quote.fiatAmount / quote.cryptoAmount
        return CurrencyFormatter(currencyCode: quote.fiatCurrency).string(amount)
    }

    private var amount: String {
        switch quote.type {
        case .buy: formatter.string(decimal: Decimal(quote.cryptoAmount))
        case .sell: formatter.string(decimal: Decimal(quote.fiatAmount))
        }
    }
}

extension FiatQuoteViewModel: Identifiable {
    public var id: String {
        "\(asset.id.identifier)\(quote.provider.name)\(quote.cryptoAmount)"
    }
}

// MARK: - SimpleListItemViewable

extension FiatQuoteViewModel: SimpleListItemViewable {
    public var image: Image {
        Images.name(quote.provider.name.lowercased().replacing(" ", with: "_"))
    }

    public var subtitle: String? { amountText }
}

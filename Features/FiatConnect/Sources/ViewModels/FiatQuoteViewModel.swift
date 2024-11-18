// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct FiatQuoteViewModel {
    private let asset: Asset
    public let quote: FiatQuote
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

    public var image: String {
        quote.provider.name.lowercased().replacing(" ", with: "_")
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

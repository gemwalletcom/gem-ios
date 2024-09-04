// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

struct FiatQuoteViewModel {
    let asset: Asset
    let quote: FiatQuote

    var title: String {
        quote.provider.name
    }
    
    var amount: String {
        let amount = CurrencyFormatter.currency().string(decimal: Decimal(quote.cryptoAmount))
        return "\(amount) \(asset.symbol)"
    }

    var rateText: String {
        let amount = quote.fiatAmount / quote.cryptoAmount
        return CurrencyFormatter(currencyCode: quote.fiatCurrency).string(amount)
    }

    var image: String {
        return quote.provider.name.lowercased().replacing(" ", with: "_")
    }
}

extension FiatQuoteViewModel: Identifiable {
    var id: String {
        "\(asset.id.identifier)\(quote.provider.name)\(quote.cryptoAmount)"
    }
}

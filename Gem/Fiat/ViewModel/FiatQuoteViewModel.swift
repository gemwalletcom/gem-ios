// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

struct FiatQuoteViewModel {
    let asset: Asset
    let quote: FiatQuote

    private let formatter = ValueFormatter(locale: .US, style: .medium)

    var title: String {
        quote.provider.name
    }
    
    var amount: String {
        "\(quote.cryptoAmount.rounded(toPlaces: 4)) \(asset.symbol)"
    }

    var formattedRate: String {
        let rate = (quote.fiatAmount / quote.cryptoAmount).rounded(toPlaces: 2)
        let bigIntRate = BigInt(rate)
        return bigIntRate.isZero ? "\(rate)" : formatter.string(bigIntRate, decimals: 0)
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

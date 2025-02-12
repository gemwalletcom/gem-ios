// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension FiatQuote {
    public static func mock(
        fiatAmount: Double = 0,
        cryptoAmount: Double = 0,
        type: FiatTransactionType = .buy,
        fiatCurrency: String = Currency.usd.rawValue
    ) -> FiatQuote {
        FiatQuote(
            provider: FiatProvider(id: UUID().uuidString, name: "", imageUrl: ""),
            type: type,
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            cryptoAmount: cryptoAmount,
            redirectUrl: ""
        )
    }
}

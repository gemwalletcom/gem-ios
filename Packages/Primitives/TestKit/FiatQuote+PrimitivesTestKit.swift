// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension FiatQuote {
    public static func mock(
        fiatAmount: Double = 0,
        cryptoAmount: Double = 0,
        fiatCurrency: String = Currency.usd.rawValue
    ) -> FiatQuote {
        FiatQuote(
            provider: FiatProvider(name: "", imageUrl: ""),
            fiatAmount: fiatAmount,
            fiatCurrency: fiatCurrency,
            cryptoAmount: cryptoAmount,
            redirectUrl: ""
        )
    }
}

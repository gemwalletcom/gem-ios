// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct FiatProvidersViewModel {
    var asset: Asset
    var quotes: [FiatQuote]

    var selectQuote: ((FiatQuote) -> Void)?

    var quotesViewModel: [FiatQuoteViewModel] {
        quotes.map { FiatQuoteViewModel(asset: asset, quote: $0) }
    }
}

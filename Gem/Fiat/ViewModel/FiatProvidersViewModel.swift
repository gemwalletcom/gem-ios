// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct FiatProvidersViewModel {
    let currentQuote: FiatQuote
    let asset: Asset
    let quotes: [FiatQuote]
    var selectQuote: ((FiatQuote) -> Void)?
    
    var quotesViewModel: [FiatQuoteViewModel] {
        return quotes.map { FiatQuoteViewModel(asset: asset, quote: $0) }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct FiatProvidersViewModel {
    let buyAssetInput: BuyAssetInputViewModel
    let asset: Asset

    var selectQuote: ((FiatQuote) -> Void)?
    var quotesViewModel: [FiatQuoteViewModel] {
        return buyAssetInput.quotes.map { FiatQuoteViewModel(asset: asset, quote: $0) }
    }
}

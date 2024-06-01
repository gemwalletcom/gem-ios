// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct FiatQuoteViewModel {
    let asset: Asset
    let quote: FiatQuote
    
    var title: String {
        return quote.provider.name
    }
    
    var amount: String {
        return  "\(quote.cryptoAmount) \(asset.symbol)"
    }
    
    var image: String {
        return quote.provider.name.lowercased().replacing(" ", with: "_")
    }
}

extension FiatQuoteViewModel: Identifiable {
    var id: String {
        return "\(asset.id.identifier)\(quote.provider.name)\(quote.cryptoAmount)"
    }
}

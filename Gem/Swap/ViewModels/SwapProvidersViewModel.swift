// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

struct SwapProvidersViewModel {
    typealias SelectQuote = (@MainActor @Sendable (SwapQuote) -> Void)

    let asset: Asset
    let swapQuotes: [SwapQuote]
    let onSelectQuote: SelectQuote?
    
    init(
        asset: Asset,
        swapQuotes: [SwapQuote],
        onSelectQuote: SelectQuote?
    ) {
        self.asset = asset
        self.swapQuotes = swapQuotes
        self.onSelectQuote = onSelectQuote
    }
    
    var items: [SwapProviderItem] {
        swapQuotes.map {
            SwapProviderItem(asset: asset, swapQuote: $0)
        }
    }
}

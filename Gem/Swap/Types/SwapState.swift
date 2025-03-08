// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Gemstone

struct SwapState {
    var fetch: SwapFetchState
    var availability: StateViewType<[SwapQuote]>
    var getQuoteData: StateViewType<Bool>

    init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapQuote]> = .noData,
        getQuoteData: StateViewType<Bool> = .noData
    ) {
        self.fetch = fetch
        self.availability = availability
        self.getQuoteData = getQuoteData
    }
}

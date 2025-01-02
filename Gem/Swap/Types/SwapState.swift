// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Swap

struct SwapState {
    var fetch: SwapFetchState
    var availability: StateViewType<SwapAvailabilityResult>
    var getQuoteData: StateViewType<Bool>

    init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<SwapAvailabilityResult> = .noData,
        getQuoteData: StateViewType<Bool> = .noData
    ) {
        self.fetch = fetch
        self.availability = availability
        self.getQuoteData = getQuoteData
    }
}

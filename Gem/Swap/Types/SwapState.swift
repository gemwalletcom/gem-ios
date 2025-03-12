// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

import struct Gemstone.SwapQuote

struct SwapState {
    var fetch: SwapFetchState
    var quotes: StateViewType<[SwapQuote]>
    var finalSwapData: StateViewType<TransferData>

    init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapQuote]> = .noData,
        finalSwapData: StateViewType<TransferData> = .noData
    ) {
        self.fetch = fetch
        self.quotes = availability
        self.finalSwapData = finalSwapData
    }

    var isLoading: Bool {
        quotes.isLoading || finalSwapData.isLoading
    }
}

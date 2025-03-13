// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives

import struct Gemstone.SwapQuote

struct SwapState {
    var fetch: SwapFetchState
    var quotes: StateViewType<[SwapQuote]>
    var swapTransferData: StateViewType<TransferData>

    init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapQuote]> = .noData,
        swapTransferData: StateViewType<TransferData> = .noData
    ) {
        self.fetch = fetch
        self.quotes = availability
        self.swapTransferData = swapTransferData
    }

    var isLoading: Bool {
        quotes.isLoading || swapTransferData.isLoading
    }
}

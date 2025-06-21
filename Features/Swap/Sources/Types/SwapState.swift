// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import struct Gemstone.SwapQuote

public struct SwapState {
    public var fetch: SwapFetchState
    public var quotes: StateViewType<[SwapQuote]>
    public var swapTransferData: StateViewType<TransferData>

    public init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapQuote]> = .noData,
        swapTransferData: StateViewType<TransferData> = .noData
    ) {
        self.fetch = fetch
        self.quotes = availability
        self.swapTransferData = swapTransferData
    }

    public var isLoading: Bool {
        quotes.isLoading || swapTransferData.isLoading
    }

    public var error: (any Error)? {
        if case .error(let error) = quotes {
            return error
        }
        if case .error(let error) = swapTransferData {
            return error
        }
        return nil
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import struct Gemstone.SwapperQuote

public struct SwapState: Sendable {
    public var fetch: SwapFetchState
    public var quotes: StateViewType<[SwapperQuote]>
    public var swapTransferData: StateViewType<TransferData>

    public init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapperQuote]> = .noData,
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

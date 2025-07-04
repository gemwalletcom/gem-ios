// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import struct Gemstone.SwapQuote

public struct SwapState {
    public var fetch: SwapFetchState
    public var quotes: StateViewType<[SwapQuote]>

    public init(
        fetch: SwapFetchState = .idle,
        availability: StateViewType<[SwapQuote]> = .noData
    ) {
        self.fetch = fetch
        self.quotes = availability
    }

    public var isLoading: Bool { quotes.isLoading }

    public var error: (any Error)? {
        if case .error(let error) = quotes {
            return error
        }
        return nil
    }
}

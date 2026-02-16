// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import struct Gemstone.SwapperQuote

public struct SwapState: Sendable {
    public var quotes: StateViewType<[SwapperQuote]>
    public var swapTransferData: StateViewType<TransferData>

    public init(
        quotes: StateViewType<[SwapperQuote]> = .noData,
        swapTransferData: StateViewType<TransferData> = .noData
    ) {
        self.quotes = quotes
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

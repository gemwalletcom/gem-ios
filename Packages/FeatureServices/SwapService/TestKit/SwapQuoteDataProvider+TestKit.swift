// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapQuoteData
import struct Gemstone.SwapperQuote
import Primitives
import SwapService

public extension SwapQuoteDataProvider {
    static func mock() -> SwapQuoteDataProviderMock {
        SwapQuoteDataProviderMock()
    }
}

public extension SwapQuoteDataProvidable where Self == SwapQuoteDataProviderMock {
    static func mock() -> SwapQuoteDataProviderMock {
        SwapQuoteDataProviderMock()
    }
}

public struct SwapQuoteDataProviderMock: SwapQuoteDataProvidable {
    public let quoteData: GemSwapQuoteData

    public init(quoteData: GemSwapQuoteData = .mock()) {
        self.quoteData = quoteData
    }

    public func fetchQuoteData(wallet: Wallet, quote: SwapperQuote) async throws -> GemSwapQuoteData {
        quoteData
    }
}

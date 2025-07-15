// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwapService
import Primitives
import Gemstone

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
    public let quoteData: Gemstone.GemSwapQuoteData
    
    public init(quoteData: Gemstone.GemSwapQuoteData = .mock()) {
        self.quoteData = quoteData
    }
    
    public func fetchQuoteData(wallet: Wallet, quote: Gemstone.SwapQuote) async throws -> Gemstone.GemSwapQuoteData {
        quoteData
    }
}

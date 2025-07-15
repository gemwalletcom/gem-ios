// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwapService
import Primitives
import struct Gemstone.SwapperQuote
import struct Gemstone.SwapperQuoteData

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
    public let quoteData: SwapperQuoteData
    
    public init(quoteData: SwapperQuoteData = .mock()) {
        self.quoteData = quoteData
    }
    
    public func fetchQuoteData(wallet: Wallet, quote: SwapperQuote) async throws -> SwapperQuoteData {
        quoteData
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import SwapService
import Primitives
import struct Gemstone.SwapperQuote

public struct SwapQuotesProviderMock: SwapQuotesProvidable {
    private let results: [Result<SwapperQuote, Error>]

    public init(results: [Result<SwapperQuote, Error>]) {
        self.results = results
    }

    public func supportedAssets(for assetId: AssetId) -> ([Primitives.Chain], [Primitives.AssetId]) {
        ([], [])
    }

    public func fetchQuotes(wallet: Wallet, input: SwapQuoteInput) -> AsyncStream<Result<SwapperQuote, Error>> {
        let results = self.results
        return AsyncStream { continuation in
            for result in results {
                continuation.yield(result)
            }
            continuation.finish()
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPIFiatServiceMock: GemAPIFiatService {
    private let quotes: [FiatQuote]
    private let quoteUrl: FiatQuoteUrl

    public init(
        quotes: [FiatQuote] = [],
        quoteUrl: FiatQuoteUrl = FiatQuoteUrl(redirectUrl: "")
    ) {
        self.quotes = quotes
        self.quoteUrl = quoteUrl
    }

    public func getQuotes(walletId: String, type: FiatQuoteType, assetId: AssetId, request: FiatQuoteRequest) async throws -> [FiatQuote] {
        quotes
    }

    public func getQuoteUrl(walletId: String, quoteId: String) async throws -> FiatQuoteUrl {
        quoteUrl
    }
}

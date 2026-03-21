// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPIFiatServiceMock: GemAPIFiatService {
    private let quotes: [FiatQuote]
    private let quoteUrl: FiatQuoteUrl
    private let fiatTransactions: [FiatTransactionInfo]

    public init(
        quotes: [FiatQuote] = [],
        quoteUrl: FiatQuoteUrl = FiatQuoteUrl(redirectUrl: ""),
        fiatTransactions: [FiatTransactionInfo] = []
    ) {
        self.quotes = quotes
        self.quoteUrl = quoteUrl
        self.fiatTransactions = fiatTransactions
    }

    public func getQuotes(walletId: String, type: FiatQuoteType, assetId: AssetId, request: FiatQuoteRequest) async throws -> [FiatQuote] {
        quotes
    }

    public func getQuoteUrl(walletId: String, quoteId: String) async throws -> FiatQuoteUrl {
        quoteUrl
    }

    public func getFiatTransactions(walletId: String) async throws -> [FiatTransactionInfo] {
        fiatTransactions
    }
}

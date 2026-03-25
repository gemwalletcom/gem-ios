// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store

public struct FiatService: Sendable {
    private let apiService: any GemAPIFiatService
    private let store: FiatTransactionStore

    public init(
        apiService: any GemAPIFiatService,
        store: FiatTransactionStore
    ) {
        self.apiService = apiService
        self.store = store
    }

    public func updateTransactions(walletId: WalletId) async throws {
        let transactions = try await apiService.getFiatTransactions(walletId: walletId.id)
        try store.addTransactions(walletId: walletId, transactions: transactions)
    }
}

extension FiatService: GemAPIFiatService {
    public func getQuotes(walletId: String, type: FiatQuoteType, assetId: AssetId, request: FiatQuoteRequest) async throws -> [FiatQuote] {
        try await apiService.getQuotes(walletId: walletId, type: type, assetId: assetId, request: request)
    }

    public func getQuoteUrl(walletId: String, quoteId: String) async throws -> FiatQuoteUrl {
        try await apiService.getQuoteUrl(walletId: walletId, quoteId: quoteId)
    }

    public func getFiatTransactions(walletId: String) async throws -> [FiatTransactionInfo] {
        try await apiService.getFiatTransactions(walletId: walletId)
    }
}

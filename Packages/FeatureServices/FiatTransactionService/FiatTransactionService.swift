// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store

public struct FiatTransactionService: Sendable {
    private let apiService: any GemAPIFiatService
    public let store: FiatTransactionStore

    public init(
        apiService: any GemAPIFiatService,
        store: FiatTransactionStore
    ) {
        self.apiService = apiService
        self.store = store
    }

    public func update(walletId: WalletId) async throws {
        let transactions = try await apiService.getFiatTransactions(walletId: walletId.id)
        try store.addTransactions(walletId: walletId, transactions: transactions)
    }
}

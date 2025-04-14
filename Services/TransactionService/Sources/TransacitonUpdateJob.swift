// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import JobRunner

public struct TransactionUpdateJob: Job {
    private let transaction: Transaction
    private let action: @Sendable (Transaction) async -> (TransactionState, Duration)

    public var id: String { transaction.hash }

    init(
        transaction: Transaction,
        action: @Sendable @escaping (Transaction) async -> (TransactionState, Duration)
    ) {
        self.transaction = transaction
        self.action = action
    }

    public func run() async -> JobStatus {
        let (transactionState, delay) = await action(transaction)
        switch transactionState {
        case .pending: return .retry(delay)
        case .failed: return .failure
        case .reverted, .confirmed: return .success
        }
    }
}

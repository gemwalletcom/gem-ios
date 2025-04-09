// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import GemstonePrimitives

public actor TransactionPoller {
    private let transactionUpdater: TransactionUpdater
    private let timerPoller: TimerPoller

    private var transactions: [Transaction] = []

    public init(transactionUpdater: TransactionUpdater) {
        self.transactionUpdater = transactionUpdater
        self.timerPoller = TimerPoller(
            configuration: TimerPollerConfiguration(
                maxInterval: .seconds(10),
                idleInterval: .seconds(5),
                stepFactor: 1.5
            )
        )
    }

    public func start(transactions: [Transaction]) async throws {
        self.transactions = transactions
        await timerPoller.start(pollAction: pollAction)
    }

    public func stop() {
        Task {
            await timerPoller.stop()
        }
    }

    public func addToPoll(transactions: [Transaction]) async throws {
        self.transactions.append(contentsOf: transactions)
        try await start(transactions: transactions)
    }

    private func pollAction() async throws -> PollResult {
        guard transactions.isNotEmpty else { return .empty }

        transactions = try await transactionUpdater.update(pendingTransactions: transactions)
        transactions.removeAll { $0.state != .pending }

        guard transactions.isNotEmpty else { return .empty }
        let recommendedInterval = transactions
            .map { Duration.milliseconds(ChainConfig.config(chain: $0.assetId.chain).blockTime) }
            .min() ?? timerPoller.configuration.idleInterval

        return PollResult(isActive: true, recommendedInterval: recommendedInterval)
    }
}

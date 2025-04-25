// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import JobRunner
import GemstonePrimitives
import Store
import ChainService
import Blockchain

public struct TransactionStateUpdateJob: Job {
    private let transaction: Transaction
    private let stateService: TransactionStateService
    private let postProcessingService: TransactionStateUpdatePostJob

    public var id: String { transaction.hash }

    public var configuration: JobConfiguration {
        .adaptive(
            configuration: AdaptiveConfiguration(
                initialInterval: .milliseconds(ChainConfig.config(chain: transaction.assetId.chain).blockTime),
                maxInterval: .seconds(10),
                stepFactor: 1.5
            ),
            timeLimit: .none
        )
    }

    init(
        transaction: Transaction,
        stateService: TransactionStateService,
        postProcessingService: TransactionStateUpdatePostJob
    ) {
        self.transaction = transaction
        self.stateService = stateService
        self.postProcessingService = postProcessingService
    }

    public func run() async -> JobStatus {
        do {
            let stateChanges = try await stateService.getState(for: transaction)

            switch stateChanges.state {
            case .pending:
                return .retry
            case .confirmed, .reverted, .failed:
                try await stateService.updateStateChanges(stateChanges, for: transaction)
                return .complete
            }
        } catch {
            let isTimedOut = Date.now.timeIntervalSince(transaction.createdAt) > timeout
            if isTimedOut {
                // mark as failed on timeout and finish job
                try? stateService.updateState(state: .failed, for: transaction)
                return .complete
            }
            return .retry
        }
    }

    public func onComplete() async throws {
        try await postProcessingService.process(transaction: transaction)
    }
}

// MARK: - Private

extension TransactionStateUpdateJob {
    private var timeout: Double {
        Double(ChainConfig.config(chain: transaction.assetId.chain).transactionTimeout)
    }
}

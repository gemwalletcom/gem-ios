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
    
    private let minInitialInterval: Duration = .seconds(5)
    
    public var configuration: JobConfiguration {
        .adaptive(
            configuration: AdaptiveConfiguration(
                initialInterval: min(
                    .milliseconds(transaction.assetId.chain.blockTime),
                    minInitialInterval
                ),
                maxInterval: minInitialInterval * 3,
                stepFactor: 1.1
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
            let isTimedOut = Date.now.timeIntervalSince(transaction.createdAt) > Double(transaction.assetId.chain.transactionTimeoutSeconds) && isNetworkError(
                error
            ) == false
            if isTimedOut {
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

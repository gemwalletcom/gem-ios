// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Store
import ChainService
import Blockchain

public struct TransactionStateUpdateJob: Job {
    private let transactionWallet: TransactionWallet
    private let stateService: TransactionStateProvider
    private let postProcessingService: TransactionPostProcessingService
    private let minInitialInterval: Duration = .seconds(5)

    public var id: String { transaction.id.identifier }

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

    private var transaction: Transaction { transactionWallet.transaction}

    init(
        transactionWallet: TransactionWallet,
        stateService: TransactionStateProvider,
        postProcessingService: TransactionPostProcessingService
    ) {
        self.transactionWallet = transactionWallet
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
            debugLog("TransactionStateUpdateJob: error \(error)")
            return .retry
        }
    }

    public func onComplete() async throws {
        try await postProcessingService.process(
            wallet: transactionWallet.wallet,
            transaction: transactionWallet.transaction
        )
    }
}

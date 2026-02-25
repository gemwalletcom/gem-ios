// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemstonePrimitives
import Store
import ChainService
import Blockchain

struct TransactionStateUpdateJob: Job {
    private let transactionWallet: TransactionWallet
    private let stateService: TransactionStateProvider
    private let swapResultProvider: SwapResultProvider
    private let postProcessingService: TransactionPostProcessingService
    private let minInitialInterval: Duration = .seconds(5)

    var id: String { transaction.id.identifier }

    var configuration: JobConfiguration {
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
        swapResultProvider: SwapResultProvider,
        postProcessingService: TransactionPostProcessingService
    ) {
        self.transactionWallet = transactionWallet
        self.stateService = stateService
        self.swapResultProvider = swapResultProvider
        self.postProcessingService = postProcessingService
    }

    func run() async -> JobStatus {
        switch transaction.state {
        case .inTransit:
            return await runWithTimeoutHandling(checkSwapStatus)
        case .pending:
            return await runWithTimeoutHandling(checkChainState)
        case .confirmed, .reverted, .failed:
            return .complete
        }
    }

    func onComplete() async throws {
        try await postProcessingService.process(
            wallet: transactionWallet.wallet,
            transaction: transactionWallet.transaction
        )
    }

    // MARK: - Private

    private func checkSwapStatus() async throws -> JobStatus {
        guard let state = try await swapResultProvider.checkSwapStatus(for: transaction) else {
            return .retry
        }
        try stateService.updateState(state: state, for: transaction)
        return .complete
    }

    private func checkChainState() async throws -> JobStatus {
        let stateChanges = try await stateService.getState(for: transaction)

        switch stateChanges.state {
        case .pending, .inTransit:
            return .retry
        case .confirmed, .reverted, .failed:
            try await stateService.updateStateChanges(stateChanges, for: transaction)
            return .complete
        }
    }

    private func runWithTimeoutHandling(_ operation: () async throws -> JobStatus) async -> JobStatus {
        do {
            return try await operation()
        } catch {
            if isTransactionTimedOut && !isNetworkError(error) {
                try? stateService.updateState(state: .failed, for: transaction)
                return .complete
            }
            debugLog("TransactionStateUpdateJob: error \(error)")
            return .retry
        }
    }

    private var isTransactionTimedOut: Bool {
        Date.now.timeIntervalSince(transaction.createdAt) > Double(transaction.assetId.chain.transactionTimeoutSeconds)
    }
}

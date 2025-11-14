// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Style

public actor TransferStateService {
    static let dismissDelay: Duration = .seconds(2)

    private let presenter: TransferStatePresenter

    private var executions: [TransferExecution] = []
    private var currentWalletId: WalletId?

    public init(presenter: TransferStatePresenter) {
        self.presenter = presenter
    }

    // MARK: - Public methods

    public func add(
        transferData: TransferData,
        wallet: Wallet,
        execute: @escaping @Sendable () async throws -> Void
    ) async {
        let execution = TransferExecution(
            wallet: wallet,
            state: .executing,
            transferData: transferData
        )
        await update(execution: execution)

        Task {
            let state: ExecutionState = await {
                do {
                    try await execute()
                    return .success
                } catch {
                    return .error(error)
                }
            }()
            await update(execution: execution.update(state: state))
        }
    }

    public func remove(execution: TransferExecution) async {
        executions.removeAll { $0.id == execution.id }
        await updatePresenter()
    }

    public func setCurrentWallet(id: WalletId) async {
        currentWalletId = id
        await updatePresenter()
    }

    // MARK: - Private methods

    private func updatePresenter() async {
        let currentExecutions = currentWalletId.map { walletId in
            executions.filter { $0.wallet.walletId == walletId }
        } ?? []

        await MainActor.run {
            presenter.executions = currentExecutions
        }
    }

    private func update(execution: TransferExecution) async {
        guard let index = executions.firstIndex(where: { $0.id == execution.id }) else {
            executions.append(execution)
            await updatePresenter()
            return
        }

        executions[index] = execution
        await updatePresenter()

        switch execution.state {
        case .success: scheduleRemoval(execution: execution)
        case .executing, .error: break
        }
    }

    private func scheduleRemoval(execution: TransferExecution) {
        Task { [weak self] in
            try? await Task.sleep(for: Self.dismissDelay)
            await self?.remove(execution: execution)
        }
    }
}

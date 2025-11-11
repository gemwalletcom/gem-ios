// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Style

public actor TransferStateService {
    static let dismissDelay: Duration = .seconds(2)

    private var executions: [TransferExecution] = [] {
        didSet { updatePresenter() }
    }
    private var currentWalletId: WalletId?
    private let presenter: TransferStatePresenter

    public init(presenter: TransferStatePresenter) {
        self.presenter = presenter
    }

    // MARK: - Public methods

    public func add(
        transferData: TransferData,
        wallet: Wallet,
        execute: @escaping @Sendable () async throws -> Void
    ) {
        let execution = TransferExecution(
            wallet: wallet,
            state: .executing,
            transferData: transferData
        )
        update(execution: execution)

        Task {
            let state: ExecutionState = await {
                do {
                    try await execute()
                    return .success
                } catch {
                    return .error(error)
                }
            }()
            update(execution: execution.update(state: state))
        }
    }

    public func remove(execution: TransferExecution) {
        executions.removeAll { $0.id == execution.id }
    }

    public func setCurrentWallet(id: WalletId) {
        currentWalletId = id
        updatePresenter()
    }

    // MARK: - Private methods

    private func updatePresenter() {
        let currentExecutions = currentWalletId.map { walletId in
            executions.filter { $0.wallet.walletId == walletId }
        } ?? []

        Task { @MainActor in
            presenter.executions = currentExecutions
        }
    }

    private func update(execution: TransferExecution) {
        guard let index = executions.firstIndex(where: { $0.id == execution.id }) else {
            executions.append(execution)
            return
        }

        executions[index] = execution

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

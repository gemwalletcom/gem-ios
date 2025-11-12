// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ExecutionState: Sendable {
    case executing
    case success
    case error(Error)

    public var priority: Int {
        switch self {
        case .executing: 3
        case .error: 2
        case .success: 1
        }
    }
}

public struct TransferExecution: Sendable, Identifiable {
    public let wallet: Wallet
    public let state: ExecutionState
    public let transferData: TransferData

    public var id: String {
        transferData.id
    }

    public init(
        wallet: Wallet,
        state: ExecutionState,
        transferData: TransferData
    ) {
        self.wallet = wallet
        self.state = state
        self.transferData = transferData
    }

    public func update(state: ExecutionState) -> TransferExecution {
        TransferExecution(
            wallet: wallet,
            state: state,
            transferData: transferData
        )
    }
}

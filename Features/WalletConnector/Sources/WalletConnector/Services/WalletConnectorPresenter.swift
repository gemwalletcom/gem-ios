// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
@MainActor
public final class WalletConnectorPresenter: Sendable {
    public var isPresentingError: String?
    public var isPresentingConnectionBar: Bool = false
    public var isPresentingSheet: WalletConnectorSheetType?

    public init() { }

    public func complete(type: WalletConnectorSheetType) {
        switch type {
        case .transferData:
            isPresentingSheet = nil
        case .connectionProposal, .signMessage:
            break
        }
    }

    public func cancelSheet(type: WalletConnectorSheetType) {
        let error = ConnectionsError.userCancelled
        switch type {
        case .transferData(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .signMessage(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .connectionProposal(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        }

        self.isPresentingSheet = nil
    }
}

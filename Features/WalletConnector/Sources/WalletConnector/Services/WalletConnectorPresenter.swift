// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
public final class WalletConnectorPresenter: Sendable {

    @MainActor
    public var isPresentingError: String?
    @MainActor
    public var isPresentingConnectionBar: Bool = false
    @MainActor
    public var isPresentingSheet: WalletConnectorSheetType?

    public init() { }

    @MainActor
    public func complete(type: WalletConnectorSheetType) {
        switch type {
        case .transferData:
            isPresentingSheet = nil
        case .connectionProposal, .signMessage:
            break
        }
    }

    @MainActor
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

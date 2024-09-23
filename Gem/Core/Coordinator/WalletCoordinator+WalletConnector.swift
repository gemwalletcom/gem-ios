// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnector
import Primitives

class TransferDataCallback<T: Identifiable>: Identifiable {
    let payload: T
    let delegate: ConfirmTransferDelegate
    
    init(
        payload: T,
        delegate: @escaping ConfirmTransferDelegate
    ) {
        self.payload = payload
        self.delegate = delegate
    }
    var id: any Hashable { payload.id }
}

extension WalletCoordinator: WalletConnectorInteractable {
    func sessionReject(error: Error) {
        let ignoreErrors = [
            "User cancelled" // User cancelled throw by WalletConnect if session proposal is rejected
        ]
        
        guard !ignoreErrors.contains(error.localizedDescription)  else {
            return
        }
        
        self.isPresentingError = error.localizedDescription
    }

    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        try await walletConnectManager.handleApproveRequest(
            payload: payload,
            isPending: lockModel.shouldShowPlaceholder
        )
    }

    func signMessage(payload: SignMessagePayload) async throws -> String {
        try await walletConnectManager.handleSignMessageRequest(
            payload: payload,
            isPending: lockModel.shouldShowPlaceholder
        )
    }

    func sendTransaction(transferData: WCTransferData) async throws -> String {
        try await walletConnectManager.handleSendTransactionRequest(
            payload: transferData,
            isPending: lockModel.shouldShowPlaceholder
        )
    }

    func signTransaction(transferData: WCTransferData) async throws -> String {
        fatalError()
    }

    func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        fatalError()
    }
}

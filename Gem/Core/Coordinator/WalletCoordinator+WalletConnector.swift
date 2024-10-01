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
    func sessionReject(error: any Error) {
        let ignoreErrors = [
            "User cancelled" // User cancelled throw by WalletConnect if session proposal is rejected
        ]
        
        guard !ignoreErrors.contains(error.localizedDescription)  else {
            return
        }
        
        self.isPresentingError = error.localizedDescription
    }

    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        return try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(value):
                    continuation.resume(with: .success(WalletId(id: value)))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.connectionProposal = transferDataCallback
        }
    }

    func signMessage(payload: SignMessagePayload) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(id):
                    continuation.resume(with: .success(id))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.signMessage = transferDataCallback
        }
    }

    func sendTransaction(transferData: WCTransferData) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: transferData) { result in
                switch result {
                case let .success(id):
                    continuation.resume(with: .success(id))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.transferData = transferDataCallback
        }
    }

    func signTransaction(transferData: WCTransferData) async throws -> String {
        fatalError()
    }

    func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        fatalError()
    }
}

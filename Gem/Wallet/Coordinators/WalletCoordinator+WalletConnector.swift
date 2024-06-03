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
    
    func sessionApproval(payload: WalletConnectionSessionProposal) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case .success:
                    continuation.resume(with: .success(true))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.connectionProposal = transferDataCallback
        }
    }
    
    func signMessage(payload: SignMessagePayload) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let signMessageCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case .success(let id):
                    continuation.resume(with: .success(id))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.signMessage = signMessageCallback
        }
    }
    
    func signTransaction(transferData: TransferData) async throws -> String {
        fatalError()
    }
    
    func sendTransaction(transferData: TransferData) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: transferData) { result in
                switch result {
                case .success(let id):
                    continuation.resume(with: .success(id))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.transferData = transferDataCallback
        }
    }
    
    func sendRawTransaction(transferData: TransferData) async throws -> String {
        fatalError()
    }
}

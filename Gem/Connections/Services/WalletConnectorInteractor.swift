// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import WalletConnector

@Observable
final class WalletConnectorInteractor {
    var isPresentingError: String? = nil
    var isPresentingConnectionBar: Bool = false

    // TODO: - isPresenting
    var action: WalletConnectAction? = nil

    init() {}

    func cancel(action: WalletConnectAction) {
        let error = ConnectionsError.userCancelled
        switch action {
        case .transferData(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .signMessage(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .connectionProposal(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        }
        
        self.action = nil
    }
}

// MARK: - WalletConnectorInteractable

extension WalletConnectorInteractor: WalletConnectorInteractable {
    func sessionReject(error: any Error) {
        let ignoreErrors = [
            "User cancelled" // User cancelled throw by WalletConnect if session proposal is rejected
        ]
        guard !ignoreErrors.contains(error.localizedDescription) else {
            return
        }
        self.isPresentingError = error.localizedDescription
    }

    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let `self` = self else { return }
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: WalletId(id: value))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.action = .connectionProposal(transferDataCallback)
        }
    }

    func signMessage(payload: SignMessagePayload) async throws -> String {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let `self` = self else { return }
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.action = .signMessage(transferDataCallback)
        }
    }

    func signTransaction(transferData: WCTransferData) async throws -> String {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let `self` = self else { return }
            let transferDataCallback = TransferDataCallback(payload: transferData) { result in
                switch result {
                case let .success(id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.action = .transferData(transferDataCallback)
        }
    }

    func sendTransaction(transferData: WCTransferData) async throws -> String {
        fatalError("not implemented")
    }

    func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        fatalError("not implemented")
    }
}

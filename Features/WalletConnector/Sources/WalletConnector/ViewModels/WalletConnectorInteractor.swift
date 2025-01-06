// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import WalletConnectorService

@Observable
@MainActor
public final class WalletConnectorInteractor {
    public var isPresentingError: String? = nil
    public var isPresentingConnectionBar: Bool = false
    public var isPresentingSheeet: WalletConnectorSheetType? = nil

    public init() {}

    public func cancel(type: WalletConnectorSheetType) {
        let error = ConnectionsError.userCancelled
        switch type {
        case .transferData(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .signMessage(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        case .connectionProposal(let transferDataCallback):
            transferDataCallback.delegate(.failure(error))
        }

        self.isPresentingSheeet = nil
    }
}

// MARK: - WalletConnectorInteractable

extension WalletConnectorInteractor: WalletConnectorInteractable {
    public func sessionReject(error: any Error) async {
        let ignoreErrors = [
            "User cancelled" // User cancelled throw by WalletConnect if session proposal is rejected
        ]
        guard !ignoreErrors.contains(error.localizedDescription) else {
            return
        }
        self.isPresentingError = error.localizedDescription
    }

    public func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
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
            self.isPresentingSheeet = .connectionProposal(transferDataCallback)
        }
    }

    public func signMessage(payload: SignMessagePayload) async throws -> String {
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
            self.isPresentingSheeet = .signMessage(transferDataCallback)
        }
    }

    public func sendTransaction(transferData: WCTransferData) async throws -> String {
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
            self.isPresentingSheeet = .transferData(transferDataCallback)
        }
    }

    public func signTransaction(transferData: WCTransferData) async throws -> String {
        fatalError("")
    }

    public func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        fatalError("")
    }
}

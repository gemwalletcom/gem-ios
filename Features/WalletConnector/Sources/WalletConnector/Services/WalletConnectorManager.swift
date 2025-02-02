// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import WalletConnectorService

public final class WalletConnectorManager {
    public let presenter: WalletConnectorPresenter

    public init(presenter: WalletConnectorPresenter) {
        self.presenter = presenter
    }
}

// MARK: - WalletConnectorInteractable

extension WalletConnectorManager: WalletConnectorInteractable {
    public func sessionReject(error: any Error) async {
        let ignoreErrors = [
            "User cancelled" // User cancelled throw by WalletConnect if session proposal is rejected
        ]
        guard !ignoreErrors.contains(error.localizedDescription) else {
            return
        }
        await MainActor.run { [weak self] in
            guard let self else { return }
            self.presenter.isPresentingError = error.localizedDescription
        }

    }

    public func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: WalletId(id: value))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.presenter.isPresentingSheet = .connectionProposal(transferDataCallback)
            }
        }
    }

    public func signMessage(payload: SignMessagePayload) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.presenter.isPresentingSheet = .signMessage(transferDataCallback)
            }
        }
    }

    public func sendTransaction(transferData: WCTransferData) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: transferData) { result in
                switch result {
                case let .success(id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.presenter.isPresentingSheet = .transferData(transferDataCallback)
            }
        }
    }

    public func signTransaction(transferData: WCTransferData) async throws -> String {
        try await self.presentPayload(transferData)
    }

    public func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        fatalError("")
    }

    private func presentPayload(_ payload: WCTransferData) async throws -> String  {
        try await withCheckedThrowingContinuation { continuation in
            let transferDataCallback = TransferDataCallback(payload: payload) { result in
                switch result {
                case let .success(id):
                    continuation.resume(returning: id)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.presenter.isPresentingSheet = .transferData(transferDataCallback)
            }
        }
    }
}

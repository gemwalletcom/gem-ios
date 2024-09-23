// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnector
import Keystore
import Primitives

@Observable
class WalletConnectManager {
    private let connectionsService: ConnectionsService
    private let keystore: LocalKeystore

    private var pendingTransferDataRequest: TransferDataCallback<WCTransferData>?
    private var pendingSignMessageRequest: TransferDataCallback<SignMessagePayload>?
    private var pendingConnectionProposal: TransferDataCallback<WCPairingProposal>?

    var transferData: TransferDataCallback<WCTransferData>?
    var signMessage: TransferDataCallback<SignMessagePayload>?
    var connectionProposal: TransferDataCallback<WCPairingProposal>?

    var isPresentingWalletConnectBar: Bool = false

    init(connectionsService: ConnectionsService, keystore: LocalKeystore) {
        self.connectionsService = connectionsService
        self.keystore = keystore
    }
}

// MARK: - Business Logic

extension WalletConnectManager {
    func handleApproveRequest(payload: WCPairingProposal, isPending: Bool) async throws -> WalletId {
        try await handleWalletConnectRequest(
            payload: payload,
            isPending: isPending,
            mapResult: { WalletId(id: $0) },
            setCurrentRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                connectionProposal = transferDataCallback
            },
            setPendingRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                pendingConnectionProposal = transferDataCallback
            }
        )
    }

    func handleSignMessageRequest(payload: SignMessagePayload, isPending: Bool) async throws -> String {
        try await handleWalletConnectRequest(
            payload: payload,
            isPending: isPending,
            mapResult: { $0 },
            setCurrentRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                signMessage = transferDataCallback
            },
            setPendingRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                pendingSignMessageRequest = transferDataCallback
            }
        )
    }

    func handleSendTransactionRequest(payload: WCTransferData, isPending: Bool) async throws -> String {
        return try await handleWalletConnectRequest(
            payload: payload,
            isPending: isPending,
            mapResult: { $0 },
            setCurrentRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                transferData = transferDataCallback
            },
            setPendingRequest: { [weak self] transferDataCallback in
                guard let `self` = self else { return }
                pendingTransferDataRequest = transferDataCallback
            }
        )
    }

    func handle(action: URLAction) async throws {
        switch action {
        case .walletConnect(let uri):
            isPresentingWalletConnectBar = true
            try await connectionsService.addConnectionURI(
                uri: uri,
                wallet: try keystore.getCurrentWallet()
            )
        case .walletConnectRequest:
            isPresentingWalletConnectBar = false
            // Handle specific WalletConnect requests if needed
        }
    }

    func cancelTransferData() {
        transferData?.delegate(.failure(ConnectionsError.userCancelled))
        transferData = nil
    }

    func cancelSignMessage() {
        signMessage?.delegate(.failure(ConnectionsError.userCancelled))
        signMessage = nil
    }

    func cancelConnectionProposal() {
        connectionProposal?.delegate(.failure(ConnectionsError.userCancelled))
        connectionProposal = nil
    }

    func setRequestsPending() {
        if let currentTransferData = transferData {
            pendingTransferDataRequest = currentTransferData
            transferData = nil
        }

        if let currentSignMessage = signMessage {
            pendingSignMessageRequest = currentSignMessage
            signMessage = nil
        }

        if let currentConnectionProposal = connectionProposal {
            pendingConnectionProposal = currentConnectionProposal
            connectionProposal = nil
        }
    }

    func processPendingRequests() {
        if let request = pendingTransferDataRequest {
            transferData = request
            pendingTransferDataRequest = nil
        }

        if let request = pendingSignMessageRequest {
            signMessage = request
            pendingSignMessageRequest = nil
        }

        if let proposal = pendingConnectionProposal {
            connectionProposal = proposal
            pendingConnectionProposal = nil
        }
    }
 }

// MARK: - Private

extension WalletConnectManager {
    private func handleWalletConnectRequest<T: Identifiable, ResultType>(
        payload: T,
        isPending: Bool,
        mapResult: @escaping (String) -> ResultType,
        setCurrentRequest: @escaping (TransferDataCallback<T>) -> Void,
        setPendingRequest: @escaping (TransferDataCallback<T>) -> Void
    ) async throws -> ResultType {
        return try await withCheckedThrowingContinuation { continuation in
            let delegate: ConfirmTransferDelegate = { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: mapResult(value))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            let transferDataCallback = TransferDataCallback(
                payload: payload,
                delegate: delegate
            )

            if isPending {
                setPendingRequest(transferDataCallback)
            } else {
                setCurrentRequest(transferDataCallback)
            }
        }
    }
}

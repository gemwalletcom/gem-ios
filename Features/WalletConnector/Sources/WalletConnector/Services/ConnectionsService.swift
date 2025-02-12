// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import WalletConnectorService
import Primitives

public final class ConnectionsService: Sendable {
    private let store: ConnectionsStore
    private let signer: any WalletConnectorSignable
    private let connector: WalletConnectorService

    public init(
        store: ConnectionsStore,
        signer: any WalletConnectorSignable
    ) {
        self.store = store
        self.signer = signer
        self.connector = WalletConnectorService(
            signer: signer
        )
    }

    public func setup() {
        Task {
            try await configure()
        }
    }

    public func addConnectionURI(uri: String, wallet: Wallet) async throws {
        let id = try await connector.addConnectionURI(uri: uri)
        let chains = signer.getChains(wallet: wallet)
        let session = WalletConnectionSession.started(id: id, chains: chains)
        let connection = WalletConnection(
            session: session,
            wallet: wallet
        )
        try? self.store.addConnection(connection)
    }

    public func updateConnection(id: String, wallet: WalletId) throws {
        try store.updateConnection(id: id, with: wallet)
    }

    public func disconnect(session: WalletConnectionSession) async throws {
        try await disconnect(
            sessionId: session.sessionId,
            pairingId: session.id
        )
    }
    
    private func configure() async throws {
        try connector.configure()
        await connector.setup()
    }

    private func disconnect(sessionId: String) async throws {
        try store.delete(ids: [sessionId])
        try await connector.disconnect(sessionId: sessionId)
    }

    private func disconnectPairing(pairingId: String) async throws {
        try store.delete(ids: [pairingId])
        await connector.disconnectPairing(pairingId: pairingId)
    }

    private func disconnect(sessionId: String, pairingId: String) async throws {
        if sessionId == pairingId {
            try await disconnectPairing(pairingId: pairingId)
        } else {
            try await disconnect(sessionId: sessionId)
            try await disconnectPairing(pairingId: pairingId)
        }
    }

}


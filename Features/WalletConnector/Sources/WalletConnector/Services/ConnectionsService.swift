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

    private func configure() async throws {
        try connector.configure()
        await connector.setup()
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

    func disconnect(sessionId: String) async throws {
        try store.delete(ids: [sessionId])
        try await connector.disconnect(sessionId: sessionId)
    }
    
    func disconnectPairing(pairingId: String) async throws {
        try store.delete(ids: [pairingId])
        await connector.disconnectPairing(pairingId: pairingId)
    }
}

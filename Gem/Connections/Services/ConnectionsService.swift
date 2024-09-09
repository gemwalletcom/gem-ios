// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import WalletConnector
import Primitives

class ConnectionsService {
    
    let store: ConnectionsStore
    let signer: WalletConnectorSignable
    let connector: WalletConnector
    
    init(
        store: ConnectionsStore,
        signer: WalletConnectorSignable
    ) {
        self.store = store
        self.signer = signer
        self.connector = WalletConnector(
            signer: signer
        )
    }
    
    func setup() {
        Task {
            await configure()
        }
    }

    private func configure() async {
        connector.configure()
        await connector.setup()
    }
    
    func addConnectionURI(uri: String, wallet: Wallet) async throws {
        let id = try await connector.addConnectionURI(uri: uri)
        let chains = signer.getChains(wallet: wallet)
        let session = WalletConnectionSession.started(id: id, chains: chains)
        let connection = WalletConnection(
            session: session,
            wallet: wallet
        )
        try? self.store.addConnection(connection)
    }

    func updateConnection(id: String, wallet: WalletId) throws {
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

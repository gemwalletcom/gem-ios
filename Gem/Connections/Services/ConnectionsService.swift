// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import WalletConnector
import Combine
import Primitives

class ConnectionsService {
    
    let store: ConnectionsStore
    let signer: WalletConnectorSignable
    let connector: WalletConnector
    
    private var sessionsObserver: AnyCancellable?
    private var proposalsObserver: AnyCancellable?
    
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
        connector.setup()
        
        NSLog("wallet connector setup")
        
        // all
        Task {
//            try await connector.disconnectAll()
//            let sessions = try store.getSessions()
//            
//            for session in sessions {
//                try store.delete(id: session.id)
//            }
        }
        
        // single
        Task {
            //let session = try store.getConnection(id: "0dc56c68346d09c4ddfff85dc5843d0ecff7309016e74f004921a0d6c6410b92")
            //try await connector.disconnect(topic: "02ebb058cbe4b798e3ca649b96e5453cad739ae5076e41ca3fa93128f182b1fb") //session.id)
            //try store.delete(id: session.id)
        }
        
//        do {
//            //try await connector.run()
//            
//            NSLog("wallet connector run")
//        } catch {
//            NSLog("wallet connector error \(error)")
//        }
    }
    
    func addConnectionURI(uri: String, wallet: Wallet) async throws {
        let id = try await connector.addConnectionURI(uri: uri)
        let chains = try signer.getChains()
        let session = WalletConnectionSession.started(id: id, chains: chains)
        let connection = WalletConnection(
            session: session,
            wallet: wallet
        )
        try? self.store.addConnection(connection)
    }
    
    func disconnect(sessionId: String) async throws {
        try store.delete(ids: [sessionId])
        try await connector.disconnect(sessionId: sessionId)
    }
    
    func disconnectPairing(pairingId: String) async throws {
        try store.delete(ids: [pairingId])
        try await connector.disconnectPairing(pairingId: pairingId)
    }
}

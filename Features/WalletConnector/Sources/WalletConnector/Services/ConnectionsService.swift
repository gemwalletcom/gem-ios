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
    
    // MARK: - Public methods

    public func setup() {
        Task {
            try await configure()
        }
    }
    
    public func pair(uri: String) async throws {
        try await connector.pair(uri: uri)
    }

    public func disconnect(session: WalletConnectionSession) async throws {
        try await disconnect(sessionId: session.sessionId)
    }
    
    // MARK: - Private methods
    
    private func configure() async throws {
        try connector.configure()
        await connector.setup()
    }

    private func disconnect(sessionId: String) async throws {
        try store.delete(ids: [sessionId])
        try await connector.disconnect(sessionId: sessionId)
    }
}


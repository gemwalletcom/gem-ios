// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import WalletConnectorService
import Primitives
import Preferences

public final class ConnectionsService: Sendable {
    private let store: ConnectionsStore
    private let signer: any WalletConnectorSignable
    private let connector: WalletConnectorService
    private let preferences: Preferences
    
    private var hasSessions: Bool {
        (try? store.getSessions().isNotEmpty) == true
    }
    
    public var isWalletConnectActivated: Bool {
        get { preferences.isWalletConnectActivated }
        set { preferences.isWalletConnectActivated = newValue }
    }
    
    public init(
        store: ConnectionsStore,
        signer: any WalletConnectorSignable,
        connector: WalletConnectorService,
        preferences: Preferences = .standard
    ) {
        self.store = store
        self.signer = signer
        self.connector = connector
        self.preferences = preferences
    }

    public convenience init(
        store: ConnectionsStore,
        signer: any WalletConnectorSignable,
        preferences: Preferences = .standard
    ) {
        self.init(
            store: store,
            signer: signer,
            connector: WalletConnectorServiceImpl(signer: signer),
            preferences: preferences
        )
    }
    
    // MARK: - Public methods

    public func setup() async throws {
        try connector.configure()
        if isWalletConnectActivated || hasSessions {
            try await setupConnector()
        }
    }

    public func pair(uri: String) async throws {
        if !isWalletConnectActivated {
            try await setupConnector()
        }
        try await connector.pair(uri: uri)
    }

    public func disconnect(session: WalletConnectionSession) async throws {
        try await disconnect(sessionId: session.sessionId)
    }
    
    public func updateSessions() {
        connector.updateSessions()
    }
    
    // MARK: - Private methods

    private func disconnect(sessionId: String) async throws {
        try store.delete(ids: [sessionId])
        try await connector.disconnect(sessionId: sessionId)
    }
    
    private func setupConnector() async throws {
        if !isWalletConnectActivated {        
            isWalletConnectActivated = true
        }
        await connector.setup()
    }
}

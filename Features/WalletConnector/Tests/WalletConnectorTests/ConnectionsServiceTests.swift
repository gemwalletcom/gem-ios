// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Preferences
import Store
import WalletConnectorServiceTestKit
import ConnectionsService
import ConnectionsServiceTestKit
@testable import WalletConnector

struct ConnectionsServiceTests {
    let preferences: Preferences = .mock()
    
    @Test
    func walletConnectActivation() async throws {
        try await firstRun()
        try await secondRun()
    }
    
    @Test
    func migration() async throws {
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        try walletStore.addWallet(.mock())
        let store = ConnectionsStore.mock(db: db)
        try store.addConnection(.mock())

        let preferences: Preferences = .mock()
        let connector = WalletConnectorServiceMock()
        let service = ConnectionsService(
            store: store,
            signer: WalletConnectorSigner.mock(),
            connector: connector,
            preferences: preferences
        )

        try await service.setup()
        await #expect(connector.isSetup == true)
        #expect(service.isWalletConnectActivated)
    }

    private func firstRun() async throws {
        let connector = WalletConnectorServiceMock()
        let service: ConnectionsService = .mock(connector: connector, preferences: preferences)

        try await service.setup()
        await #expect(connector.isSetup == false)
        #expect(service.isWalletConnectActivated == false)
        
        try await service.pair(uri: .empty)
        await #expect(connector.isSetup == true)
        #expect(service.isWalletConnectActivated)
    }
    
    private func secondRun() async throws {
        let connector = WalletConnectorServiceMock()
        let service: ConnectionsService = .mock(connector: connector, preferences: preferences)

        try await service.setup()
        await #expect(connector.isSetup == true)
        #expect(service.isWalletConnectActivated)
    }
}

extension ConnectionsService {
    static func mock(
        connector: WalletConnectorServiceMock,
        preferences: Preferences
    ) -> ConnectionsService {
        ConnectionsService(
            store: .mock(),
            signer: WalletConnectorSigner.mock(),
            connector: connector,
            preferences: preferences
        )
    }
}

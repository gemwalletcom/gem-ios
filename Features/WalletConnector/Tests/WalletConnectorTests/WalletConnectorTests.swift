import Testing
import Primitives
import Foundation
import WalletConnectSign
import Store
import PrimitivesTestKit
import StoreTestKit
import PreferencesTestKit
import WalletSessionServiceTeskKit
import WalletSessionService

@testable import WalletConnector

struct WalletConnectorSignerTests {
    @Test
    func testGetWalletsSuccess() throws {
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        let sessionService = WalletSessionService.mock(store: walletStore)
        let signer = WalletConnectorSigner.mock(
            connectionsStore: ConnectionsStore(db: db),
            walletSessionService: sessionService
        )

        try walletStore.addWallet(.mock(accounts: [.mock(chain: .ethereum), .mock(chain: .solana)]))
        let wallets = try signer.getWallets(for: .mock())

        #expect(try walletStore.getWallets() == wallets)
    }

    @Test
    func testGetWalletsEmptyNoMatchingChain() throws {
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        let sessionService = WalletSessionService.mock(store: walletStore)
        let signer = WalletConnectorSigner.mock(
            connectionsStore: ConnectionsStore(db: db),
            walletSessionService: sessionService
        )

        try walletStore.addWallet(.mock())
        let wallets = try signer.getWallets(for: try .emptyRequiredNamespaces())

        #expect(wallets.isEmpty)
    }

    @Test
    func testGetWalletsOptionalsBlockhain() throws {
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        let sessionService = WalletSessionService.mock(store: walletStore)
        let signer = WalletConnectorSigner.mock(
            connectionsStore: ConnectionsStore(db: db),
            walletSessionService: sessionService
        )
        try walletStore.addWallet(.mock(accounts: [.mock(chain: .ethereum)]))
        let wallets = try signer.getWallets(for: .optionalNamespaces())

        #expect(wallets.count == 1)
    }
}

extension WalletConnectorSigner {
    static func mock(
        connectionsStore: ConnectionsStore = .mock(),
        walletSessionService: any WalletSessionManageable = WalletSessionService.mock(
            store: .mock(),
            preferences: .mock()
        )
    ) -> WalletConnectorSigner {
        WalletConnectorSigner(
            connectionsStore: connectionsStore,
            walletSessionService: walletSessionService,
            walletConnectorInteractor: WalletConnectorManager(presenter: WalletConnectorPresenter())
        )
    }
}

extension Session.Proposal {
    static func mock() throws -> Session.Proposal {
        try Bundle.decode(from: "Proposal", withExtension: "json", in: .module)
    }

    static func emptyRequiredNamespaces() throws -> Session.Proposal {
        try Bundle.decode(from: "EmptyRequiredNamespacesProposal", withExtension: "json", in: .module)
    }
    
    static func optionalNamespaces() throws -> Session.Proposal {
        try Bundle.decode(from: "OptionalNamespacesProposal", withExtension: "json", in: .module)
    }
}

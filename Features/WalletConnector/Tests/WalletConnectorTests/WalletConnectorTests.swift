import Testing
import Keystore
import KeystoreTestKit
import Primitives
import Foundation
import WalletConnectSign
import GRDB
import Store
import PrimitivesTestKit
import StoreTestKit
import PreferencesTestKit

@testable import WalletConnector

struct WalletConnectorSignerTests {
    @Test
    func testGetWalletsSuccess() throws {
        let db = DB.mock()
        let keystore = LocalKeystore.mock(walletStore: .mock(db: db))
        let _ = try keystore.importWallet(
            name: "test",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .solana])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore, walletStore: .mock(db: db))
        let wallets = try signer.getWallets(for: try .mock())

        #expect(keystore.wallets.first == wallets.first)
    }

    @Test
    func testGetWalletsEmptyNoMatchingChain() throws {
        let db = DB.mock()
        let keystore = LocalKeystore.mock(walletStore: .mock(db: db))
        let _ = try keystore.importWallet(
            name: "test",
            type: .phrase(words:  LocalKeystore.words, chains: [])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore, walletStore: .mock(db: db))
        let wallets = try signer.getWallets(for: try .mock())

        #expect(wallets.isEmpty)
    }

    @Test
    func testGetWalletsOptionalsBlockhain() throws {
        let db = DB.mock()
        let keystore = LocalKeystore.mock(walletStore: .mock(db: db))
        let proposal = try Session.Proposal.optionalNamespaces()
    
        let _ = try keystore.importWallet(
            name: "test",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore, walletStore: .mock(db: db))
        let wallets = try signer.getWallets(for: proposal)

        #expect(wallets.count == 1)
    }
}

extension WalletConnectorSigner {
    static func mock(keystore: LocalKeystore, walletStore: WalletStore) -> WalletConnectorSigner {
        WalletConnectorSigner(
            connectionsStore: .mock(),
            walletStore: walletStore,
            preferences: .mock(),
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

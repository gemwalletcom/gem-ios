import Testing
import Keystore
import KeystoreTestKit
import Primitives
import Foundation
import WalletConnectSign
import GRDB
import Store
import PrimitivesTestKit

@testable import WalletConnector

@MainActor
struct WalletConnectorSignerTests {
    let keystore = LocalKeystore.mock()

    @Test
    func testGetWalletsSuccess() throws {
        let _ = try keystore.importWallet(
            name: "test",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .solana])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore)
        let wallets = try signer.getWallets(for: try .mock())

        #expect(keystore.currentWallet == wallets.first)
    }

    @Test
    func testGetWalletsEmptyNoMatchingChain() throws {
        let _ = try keystore.importWallet(
            name: "test",
            type: .phrase(words:  LocalKeystore.words, chains: [])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore)
        let wallets = try signer.getWallets(for: try .mock())

        #expect(wallets.isEmpty)
    }

    @Test
    func testGetWalletsNoRequiredBlockhain() throws {
        var proposal = try Session.Proposal.emptyRequiredNamespaces()
        let wallet = try keystore.importWallet(
            name: "test",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        let signer = WalletConnectorSigner.mock(keystore: keystore)
        let wallets = try signer.getWallets(for: proposal)

        #expect(wallets.contains(wallet))
    }
}

extension WalletConnectorSigner {
    @MainActor
    static func mock(keystore: LocalKeystore) -> WalletConnectorSigner {
        WalletConnectorSigner(
            store: ConnectionsStore(db: DB(path: "\(NSUUID().uuidString).sqlite")),
            keystore: keystore,
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
}

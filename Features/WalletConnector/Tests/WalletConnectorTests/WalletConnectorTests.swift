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

struct WalletConnectorSignerTests {

    let keystore = LocalKeystore.mock()

    @MainActor @Test()
    func getWallets_success() throws {
        let _ = try keystore.importWallet(name: "test", type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .solana]))
        let signer = WalletConnectorSigner.mock(keystore: keystore)
        let wallets = try signer.getWallets(for: try .mock())
        
        #expect(keystore.currentWallet == wallets.first)
    }
    
    @MainActor @Test()
    func getWallets_empty() throws {
        let _ = try keystore.importWallet(name: "test", type: .phrase(words:  LocalKeystore.words, chains: []))
        let signer = WalletConnectorSigner.mock(keystore: keystore)
        let wallets = try signer.getWallets(for: try .mock())
        
        #expect(wallets.isEmpty)
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
}

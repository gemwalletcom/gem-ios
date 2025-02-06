import Testing
import Keystore
import KeystoreTestKit
import Primitives
import Foundation
import WalletConnectSign
import GRDB
import Store

@testable import WalletConnector

struct WalletConnectorSignerTests {
    
    let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]
    let keystore = LocalKeystore.mock()

    @MainActor @Test()
    func getWallets_success() throws {
        let _ = try keystore.importWallet(name: "test", type: .phrase(words: words, chains: [.ethereum, .solana]))
        let signer = WalletConnectorSigner(
            store: ConnectionsStore(db: DB(path: "\(NSUUID().uuidString).sqlite")),
            keystore: keystore,
            walletConnectorInteractor: WalletConnectorManager(presenter: WalletConnectorPresenter())
        )
        let proposal = try Session.Proposal.mock()
        let wallets = try signer.getWallets(for: proposal)
        
        #expect(keystore.currentWallet == wallets.first)
    }
    
    @MainActor @Test()
    func getWallets_empty() throws {
        let _ = try keystore.importWallet(name: "test", type: .phrase(words: words, chains: []))
        let signer = WalletConnectorSigner(
            store: ConnectionsStore(db: DB(path: "\(NSUUID().uuidString).sqlite")),
            keystore: keystore,
            walletConnectorInteractor: WalletConnectorManager(presenter: WalletConnectorPresenter())
        )
        let proposal = try Session.Proposal.mock()
        let wallets = try signer.getWallets(for: proposal)
        
        #expect(wallets.isEmpty)
    }
}

extension Session.Proposal {
    static func mock() throws -> Session.Proposal {
        guard let proposalURL = Bundle.module.url(forResource: "Proposal", withExtension: "json") else {
            throw AnyError("Can't find Proposal.json")
        }

        let proposalData = try Data(contentsOf: proposalURL)
        let proposal = try JSONDecoder().decode(Session.Proposal.self, from: proposalData)
        return proposal
    }
}

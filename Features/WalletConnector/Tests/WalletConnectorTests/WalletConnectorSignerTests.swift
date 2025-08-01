import Testing
import Primitives
import Foundation
import WalletConnectSign
import Store
import PrimitivesTestKit
import StoreTestKit
import PreferencesTestKit
import WalletSessionServiceTestKit
import WalletSessionService

@testable import WalletConnector

struct WalletConnectorSignerTests {
    @Test
    func getWalletsRequiredChains() throws {
        let ethOnlyWallet = Wallet.mock(id: "1", accounts: [.mock(chain: .ethereum)])
        let ethPolygonWallet = Wallet.mock(id: "2", accounts: [.mock(chain: .ethereum), .mock(chain: .polygon)])
        let solanaWallet = Wallet.mock(id: "3", accounts: [.mock(chain: .solana)])
        
        let signer = try WalletConnectorSigner.mock(wallets: [ethOnlyWallet, ethPolygonWallet, solanaWallet])

        let matchingWallets = try signer.getWallets(for: .requiredChains())
        let noMatchWallets = try signer.getWallets(for: .requiredChainsNoMatch())
        
        #expect(matchingWallets.count == 1)
        #expect(matchingWallets.first?.walletId == ethPolygonWallet.walletId)
        #expect(noMatchWallets.isEmpty)
    }

    @Test
    func getWalletsOptionalChains() throws {
        let regularWallet = Wallet.mock(id: "1", accounts: [.mock(chain: .ethereum)])
        let viewOnlyWallet = Wallet.mock(id: "2", type: .view, accounts: [.mock(chain: .ethereum)])
        let bitcoinWallet = Wallet.mock(id: "3", accounts: [.mock(chain: .bitcoin)])
        
        let signer = try WalletConnectorSigner.mock(wallets: [regularWallet, viewOnlyWallet, bitcoinWallet])

        let matchingWallets = try signer.getWallets(for: .multiOptionalNamespaces())
        let emptyOptionalWallets = try signer.getWallets(for: .emptyOptionalChains())
        
        #expect(matchingWallets.count == 1)
        #expect(matchingWallets.first?.walletId == regularWallet.walletId)
        #expect(emptyOptionalWallets.count == 2)
    }

    @Test
    func getWalletsMultiOptionalNamespaces() throws {
        let solWallet = Wallet.mock(id: "1", accounts: [.mock(chain: .solana)])
        let solEthWallet = Wallet.mock(id: "2", accounts: [.mock(chain: .solana), .mock(chain: .ethereum)])
        let solEthBnbWallet = Wallet.mock(id: "3", accounts: [.mock(chain: .solana), .mock(chain: .ethereum), .mock(chain: .smartChain)])
        
        let signer = try WalletConnectorSigner.mock(wallets: [solWallet, solEthWallet, solEthBnbWallet])

        let wallets = try signer.getWallets(for: .multiOptionalNamespaces())
        
        #expect(wallets.count == 2)
        #expect(wallets.contains(where: { $0.walletId == solEthWallet.walletId }))
        #expect(wallets.contains(where: { $0.walletId == solEthBnbWallet.walletId }))
    }

    @Test
    func getWalletsMixedRequiredOptional() throws {
        let ethOnlyWallet = Wallet.mock(id: "1", accounts: [.mock(chain: .ethereum)])
        let ethPolygonWallet = Wallet.mock(id: "2", accounts: [.mock(chain: .ethereum), .mock(chain: .polygon)])
        let ethPolygonSolanaWallet = Wallet.mock(id: "3", accounts: [.mock(chain: .ethereum), .mock(chain: .polygon), .mock(chain: .solana)])
        
        let signer = try WalletConnectorSigner.mock(wallets: [ethOnlyWallet, ethPolygonWallet, ethPolygonSolanaWallet])

        let wallets = try signer.getWallets(for: .mixedRequiredOptional())
        
        #expect(wallets.count == 1)
        #expect(wallets.first?.walletId == ethPolygonSolanaWallet.walletId)
    }

    @Test
    func getWalletsNonEIP155Optional() throws {
        let ethWallet = Wallet.mock(id: "1", accounts: [.mock(chain: .ethereum)])
        let bitcoinWallet = Wallet.mock(id: "2", accounts: [.mock(chain: .bitcoin)])
        let cosmosWallet = Wallet.mock(id: "3", accounts: [.mock(chain: .cosmos)])
        
        let signer = try WalletConnectorSigner.mock(wallets: [ethWallet, bitcoinWallet, cosmosWallet])

        let wallets = try signer.getWallets(for: .nonEIP155Optional())
        
        #expect(wallets.count == 1)
        #expect(wallets.first?.walletId == cosmosWallet.walletId)
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
    
    static func mock(wallets: [Wallet]) throws -> WalletConnectorSigner {
        let db = DB.mock()
        let walletStore = WalletStore(db: db)
        for wallet in wallets {
            try walletStore.addWallet(wallet)
        }
        
        return WalletConnectorSigner.mock(
            connectionsStore: ConnectionsStore(db: db),
            walletSessionService: WalletSessionService.mock(store: walletStore))
    }
}

extension Session.Proposal {
    static func requiredChains() throws -> Session.Proposal {
        try Bundle.decode(from: "RequiredChainsProposal", withExtension: "json", in: .module)
    }
    
    static func requiredChainsNoMatch() throws -> Session.Proposal {
        try Bundle.decode(from: "RequiredChainsNoMatchProposal", withExtension: "json", in: .module)
    }

    static func emptyOptionalChains() throws -> Session.Proposal {
        try Bundle.decode(from: "EmptyOptionalChainsProposal", withExtension: "json", in: .module)
    }
    
    static func multiOptionalNamespaces() throws -> Session.Proposal {
        try Bundle.decode(from: "MultiOptionalNamespacesProposal", withExtension: "json", in: .module)
    }
    
    static func mixedRequiredOptional() throws -> Session.Proposal {
        try Bundle.decode(from: "MixedRequiredOptionalProposal", withExtension: "json", in: .module)
    }
    
    static func nonEIP155Optional() throws -> Session.Proposal {
        try Bundle.decode(from: "NonEIP155OptionalProposal", withExtension: "json", in: .module)
    }
}

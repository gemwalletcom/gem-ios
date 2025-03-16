import Foundation
import Primitives
import Store
import WalletCore
import Preferences
import WalletSessionService

// TODO: - Add keystore Config with direcotry, folder, etc and inject into LocalKeystore
// TODO: - move walletStore logic on top of ManageWalletService(should be extended ) and remove it dependecy

public struct LocalKeystore: Keystore {
    public let directory: URL

    private let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let walletStore: WalletStore
    private let walletKeyStore: WalletKeyStore
    private let keystorePassword: KeystorePassword
    private let walletSessionService: any WalletSessionManageable

    public init(
        folder: String = "keystore",
        walletStore: WalletStore,
        preferences: ObservablePreferences,
        keystorePassword: KeystorePassword = LocalKeystorePassword()
    ) {
        let directory = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, folder))
        self.directory = directory
        self.walletKeyStore = WalletKeyStore(directory: directory)
        self.walletStore = walletStore
        self.keystorePassword = keystorePassword
        self.walletSessionService = WalletSessionService(walletStore: walletStore, preferences: preferences)
    }

    public var wallets: [Primitives.Wallet] {
        (try? walletSessionService.getWallets()).or([])
    }

    public func createWallet() -> [String] {
        walletKeyStore.createWallet()
    }

    public func importWallet(name: String, type: KeystoreImportType) throws -> Primitives.Wallet {
        let result: Primitives.Wallet
        switch type {
        case .phrase(let words, let chains):
            result = try walletKeyStore.importWallet(name: name, words: words, chains: chains, password: try getOrCreatePassword())
        case .single(let words, let chain):
            result = try walletKeyStore.importWallet(name: name, words: words, chains: [chain], password: try getOrCreatePassword())
        case .privateKey(let text, let chain):
            result = try walletKeyStore.importPrivateKey(name: name, key: text, chain: chain, password: try getOrCreatePassword())
        case .address(let chain, let address):
            result = Wallet.makeView(name: name, chain: chain, address: address)
        }
        try walletStore.addWallet(result)
        walletSessionService.setCurrent(walletId: result.walletId)
        return result
    }
    
    public func setupChains(chains: [Chain]) throws {
        let setupWallets = walletSessionService.wallets.filter { $0.type == .multicoin }.compactMap {
            let enableChains = $0.accounts
                .map { $0.chain }.asSet()
                .intersection(chains)
                .map { $0 }
            
            let missingChains = Array(chains.asSet().subtracting(enableChains).map { $0 })
            
            if missingChains.count > 0 {
                return [$0: missingChains]
            }
            return .none
        }.flatMap { $0 }
        
        guard !setupWallets.isEmpty else {
            return
        }
        let password = try keystorePassword.getPassword()
        
        for (wallet, chains) in setupWallets {
            switch wallet.type {
            case .multicoin:
                let result = try walletKeyStore.addChains(chains: chains, wallet: wallet, password: password)
                try walletStore.addWallet(result)
            case .single, .privateKey:
                fatalError()
            case .view:
                break
            }
        }
    }
    
    public func deleteWallet(for wallet: Primitives.Wallet) throws {
        switch wallet.type {
        case .view:
            break
        case .multicoin, .single, .privateKey:
            let password = try keystorePassword.getPassword()
            do {
                try walletKeyStore.deleteWallet(id: wallet.id, password: password)
            } catch let error as KeystoreError {
                //in some cases wallet already deleted, just ignore
                switch error {
                case .unknownWalletInWalletCore, .unknownWalletIdInWalletCore, .unknownWalletInWalletCoreList, .invalidPrivateKey:
                    break
                }
            }
        }
        try walletStore.deleteWallet(for: wallet.id)
        walletSessionService.setCurrent(walletId: wallets.first?.walletId)
    }
    
    public func getNextWalletIndex() throws -> Int {
        try walletStore.nextWalletIndex()
    }
    
    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain) throws -> Data {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.getPrivateKey(id: wallet.id, type: wallet.type, chain: chain, password: password)
    }

    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String {
        let data = try getPrivateKey(wallet: wallet, chain: chain)
        switch encoding {
        case .base58:
            return Base58.encodeNoCheck(data: data)
        case .hex:
            return data.hexString.append0x
        }
    }

    public func getMnemonic(wallet: Primitives.Wallet) throws -> [String] {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.getMnemonic(wallet: wallet, password: password)
    }
    
    public func getPasswordAuthentication() throws -> KeystoreAuthentication {
        return try keystorePassword.getAuthentication()
    }
    
    public func sign(wallet: Primitives.Wallet, message: SignMessage, chain: Chain) throws -> Data {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.sign(message: message, walletId: wallet.id, type: wallet.type, password: password, chain: chain)
    }
    
    public func destroy() throws {
        try walletKeyStore.destroy()
        //try keystorePassword.remove()
    }

    private func getOrCreatePassword() throws -> String {
        // setup once
        var password = try keystorePassword.getPassword()
        if password.isEmpty && walletSessionService.wallets.isEmpty {
            let newPassword = NSUUID().uuidString
            // initial set / no biometrics
            try keystorePassword.setPassword(newPassword, authentication: .none)
            password = newPassword
        }
        return password
    }
}

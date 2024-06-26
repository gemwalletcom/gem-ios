import Foundation
import Primitives
import Store

public final class LocalKeystore: Keystore {
    public let directory: URL

    private let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let walletStore: WalletStore
    private let preferences: Preferences
    private let walletKeyStore: WalletKeyStore
    
    let keystorePassword: KeystorePassword
    
    @Published public var currentWallet: Primitives.Wallet? = .none
    
    public init(
        folder: String = "keystore",
        walletStore: WalletStore,
        preferences: Preferences,
        keystorePassword: KeystorePassword = LocalKeystorePassword()
    ) {
        let directory = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, folder))
        self.directory = directory
        self.walletKeyStore = WalletKeyStore(directory: directory)
        self.preferences = preferences
        self.walletStore = walletStore
        self.keystorePassword = keystorePassword
        self.currentWallet = getCurrentWallet(id: preferences.currentWallet ?? "")
    }
    
    public var wallets: [Primitives.Wallet] {
        do {
            return try walletStore.getWallets()
        } catch {
            return []
        }
    }
    
    public func createWallet() -> [String] {
        return walletKeyStore.createWallet()
    }
    
    public func setCurrentWallet(wallet: Primitives.Wallet?) {
        preferences.currentWallet = wallet?.id
        guard let wallet = wallet else {
            currentWallet = nil
            return
        }
        currentWallet = getCurrentWallet(id: wallet.id)
    }

    private func getCurrentWallet(id: String) -> Primitives.Wallet? {
        return wallets.filter({ $0.id == id  }).first ?? wallets.first
    }

    public func importWallet(name: String, type: KeystoreImportType) throws -> Primitives.Wallet {
        // setup once
        var password = try keystorePassword.getPassword()
        if password.isEmpty && wallets.isEmpty {
            let newPassword = NSUUID().uuidString
            // initial set / no biometrics
            try keystorePassword.setPassword(newPassword, authentication: .none)
            password = newPassword
        }
        
        let result: Primitives.Wallet
        switch type {
        case .phrase(let words, let chains):
            result = try walletKeyStore.importWallet(name: name, words: words, chains: chains, password: password)
        case .single(let words, let chain):
            result = try walletKeyStore.importWallet(name: name, words: words, chains: [chain], password: password)
        case .privateKey(let text, let chain):
            result = try walletKeyStore.importPrivateKey(name: name, key: text, chain: chain, password: password)
        case .address(let chain, let address):
            result = Wallet.makeView(name: name, chain: chain, address: address)
        }
        try walletStore.addWallet(result)
        setCurrentWallet(wallet: result)
        return result
    }
    
    public func setupChains(chains: [Chain]) throws {
        let setupWallets = wallets.filter { $0.type == .multicoin }.compactMap {
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
            case .single:
                fatalError()
            case .view:
                break
            }
        }
    }

    public func renameWallet(wallet: Wallet, newName: String) throws {
        return try walletStore.renameWallet(wallet.id, name: newName)
    }
    
    public func deleteWallet(for wallet: Wallet) throws {
        switch wallet.type {
        case .view:
            break
        case .multicoin, .single:
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
        setCurrentWallet(wallet: wallets.first)
    }
    
    public func getNextWalletIndex() throws -> Int {
        try walletStore.nextWalletIndex()
    }
    
    public func getPrivateKey(wallet: Wallet, chain: Chain) throws -> Data {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.getPrivateKey(id: wallet.id, chain: chain, password: password)
    }
    
    public func getMnemonic(wallet: Wallet) throws -> [String] {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.getMnemonic(wallet: wallet, password: password)
    }
    
    public func getPasswordAuthentication() throws -> KeystoreAuthentication {
        return try keystorePassword.getAuthentication()
    }
    
    public func sign(wallet: Wallet, message: SignMessage, chain: Chain) throws -> Data {
        let password = try keystorePassword.getPassword()
        return try walletKeyStore.sign(message: message, walletId: wallet.id, password: password, chain: chain)
    }
    
    public func destroy() throws {
        try walletKeyStore.destroy()
        //try keystorePassword.remove()
    }
}

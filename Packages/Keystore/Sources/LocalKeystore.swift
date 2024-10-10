import Foundation
import Primitives
import Store
import WalletCore

public final class LocalKeystore: Keystore {
    public let directory: URL

    private let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let walletStore: WalletStore
    private let preferences: Preferences
    private let walletKeyStore: WalletKeyStore
    
    let keystorePassword: KeystorePassword
    
    @Published public var currentWalletId: Primitives.WalletId? = .none
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
        self.currentWalletId = switch preferences.currentWalletId {
        case .some(let value): WalletId(id: value)
        case .none: .none
        }
        self.currentWallet = getWalletById(id: preferences.currentWalletId ?? "")
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

    public func getCurrentWallet() throws -> Primitives.Wallet {
        if let currentWalletId {
            return try getWallet(currentWalletId)
        }
        throw KeystoreError.noWalletId
    }

    public func getWallet(_ walletId: WalletId) throws -> Primitives.Wallet {
        if let wallet = getWalletById(id: walletId.id) {
            return wallet
        }
        throw KeystoreError.noWallet
    }

    public func setCurrentWalletId(_ walletId: Primitives.WalletId?) {
        preferences.currentWalletId = walletId?.id
        guard let walletId = walletId else {
            currentWallet = nil
            currentWalletId = nil
            return
        }
        currentWalletId = walletId
        currentWallet = getWalletById(id: walletId.id)
    }

    public func setCurrentWalletIndex(_ index: Int) {
        setCurrentWalletId(getWalletByIndex(index: index)?.walletId)
    }

    private func getWalletById(id: String) -> Primitives.Wallet? {
        return wallets.filter({ $0.id == id  }).first ?? wallets.first
    }

    private func getWalletByIndex(index: Int) -> Primitives.Wallet? {
        return wallets.filter({ $0.index == index  }).first ?? wallets.first
    }

    private func getOrCreatePassword() throws -> String {
        // setup once
        var password = try keystorePassword.getPassword()
        if password.isEmpty && wallets.isEmpty {
            let newPassword = NSUUID().uuidString
            // initial set / no biometrics
            try keystorePassword.setPassword(newPassword, authentication: .none)
            password = newPassword
        }
        return password
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
        setCurrentWalletId(result.walletId)
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
            case .single, .privateKey:
                fatalError()
            case .view:
                break
            }
        }
    }

    public func renameWallet(wallet: Primitives.Wallet, newName: String) throws {
        return try walletStore.renameWallet(wallet.id, name: newName)
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
                case .unknownWalletInWalletCore, .unknownWalletIdInWalletCore, .unknownWalletInWalletCoreList, .invalidPrivateKey, .noWallet, .noWalletId:
                    break
                }
            }
        }
        try walletStore.deleteWallet(for: wallet.id)
        setCurrentWalletId(wallets.first?.walletId)
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
        return try walletKeyStore.sign(message: message, walletId: wallet.id, password: password, chain: chain)
    }
    
    public func destroy() throws {
        try walletKeyStore.destroy()
        //try keystorePassword.remove()
    }
}

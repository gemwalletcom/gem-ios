import Foundation
import Primitives
import WalletCore

public struct LocalKeystore: Keystore {
    private let walletKeyStore: WalletKeyStore
    private let keystorePassword: KeystorePassword

    public init(
        directory: String = "keystore",
        keystorePassword: KeystorePassword = LocalKeystorePassword()
    ) {
        do {
            // migrate keystore from documents directory to applocation support directory
            // TODO: delete in 2026
            let fileMigrator = FileMigrator()
            let keystoreURL = try fileMigrator.migrate(
                name: directory,
                fromDirectory: .documentDirectory,
                toDirectory: .applicationSupportDirectory,
                isDirectory: true
            )
            self.walletKeyStore = WalletKeyStore(directory: keystoreURL)
        } catch {
            fatalError("keystore initialization error: \(error)")
        }

        self.keystorePassword = keystorePassword
    }

    public func createWallet() -> [String] {
        walletKeyStore.createWallet()
    }

    public func importWallet(
        name: String,
        type: KeystoreImportType,
        isWalletsEmpty: Bool
    ) throws -> Primitives.Wallet {
        return switch type {
        case .phrase(let words, let chains):
            try walletKeyStore.importWallet(
                name: name,
                words: words,
                chains: chains,
                password: try getOrCreatePassword(createPasswordIfNone: isWalletsEmpty)
            )
        case .single(let words, let chain):
            try walletKeyStore.importWallet(
                name: name,
                words: words,
                chains: [chain],
                password: try getOrCreatePassword(createPasswordIfNone: isWalletsEmpty)
            )
        case .privateKey(let text, let chain):
            try walletKeyStore.importPrivateKey(
                name: name,
                key: text,
                chain: chain,
                password: try getOrCreatePassword(createPasswordIfNone: isWalletsEmpty)
            )
        case .address(let chain, let address):
            Wallet.makeView(name: name, chain: chain, address: address)
        }
    }
    
    public func setupChains(chains: [Chain], for wallets: [Primitives.Wallet]) throws -> [Primitives.Wallet] {
        let wallets = wallets.filter {
            let enabled = Set($0.accounts.map(\.chain)).intersection(chains).map { $0 }
            let missing = Set(chains).subtracting(enabled)
            return missing.isNotEmpty
        }
        guard wallets.isNotEmpty else {
            return []
        }
        let password = try keystorePassword.getPassword()
        return try wallets
            .map {
                try walletKeyStore.addChains(
                    chains:   chains,
                    wallet:   $0,
                    password: password
                )
            }
    }
    
    public func deleteKey(for wallet: Primitives.Wallet) throws {
        switch wallet.type {
        case .view: break
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
        try walletKeyStore.getMnemonic(
            wallet: wallet,
            password: try keystorePassword.getPassword()
        )
    }
    
    public func getPasswordAuthentication() throws -> KeystoreAuthentication {
        try keystorePassword.getAuthentication()
    }
    
    public func sign(hash: Data, wallet: Primitives.Wallet, chain: Chain) throws -> Data {
        try walletKeyStore.sign(
            hash: hash,
            walletId: wallet.id,
            type: wallet.type,
            password: try keystorePassword.getPassword(),
            chain: chain
        )
    }
    
    public func destroy() throws {
        try walletKeyStore.destroy()
        //try keystorePassword.remove()
    }

    private func getOrCreatePassword(createPasswordIfNone: Bool) throws -> String {
        let password = try keystorePassword.getPassword()

        guard password.isEmpty, createPasswordIfNone else {
            return password
        }
        // setup once
        let newPassword = UUID().uuidString
        try keystorePassword.setPassword(newPassword, authentication: .none)
        return newPassword
    }
}

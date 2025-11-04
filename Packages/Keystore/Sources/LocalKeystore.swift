import Foundation
import Primitives
import WalletCore

public final class LocalKeystore: Keystore, @unchecked Sendable {
    private let walletKeyStore: WalletKeyStore
    private let keystorePassword: KeystorePassword
    private let queue = DispatchQueue(label: "com.gemwallet.keystore", qos: .userInitiated)

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
    ) async throws -> Primitives.Wallet {
        let password = try await getOrCreatePassword(createPasswordIfNone: isWalletsEmpty)

        return try await queue.asyncTask { [walletKeyStore] in
            switch type {
            case .phrase(let words, let chains):
                try walletKeyStore.importWallet(name: name, words: words, chains: chains, password: password)
            case .single(let words, let chain):
                try walletKeyStore.importWallet(name: name, words: words, chains: [chain], password: password)
            case .privateKey(let text, let chain):
                try walletKeyStore.importPrivateKey(name: name, key: text, chain: chain, password: password)
            case .address(let chain, let address):
                Wallet.makeView(name: name, chain: chain, address: address)
            }
        }
    }

    public func setupChains(chains: [Chain], for wallets: [Primitives.Wallet]) throws -> [Primitives.Wallet] {
        let filteredWallets = wallets.filter {
            let enabled = Set($0.accounts.map(\.chain)).intersection(chains).map { $0 }
            let missing = Set(chains).subtracting(enabled)
            return missing.isNotEmpty
        }
        guard filteredWallets.isNotEmpty else {
            return []
        }
        let password = try keystorePassword.getPassword()

        return try filteredWallets
            .prefix(25)
            .map {
                let existingChains = $0.accounts.map(\.chain)
                return try walletKeyStore.addChains(
                    wallet: $0,
                    existingChains: existingChains,
                    newChains: chains.asSet().subtracting(existingChains.asSet()).asArray(),
                    password: password
                )
            }
    }

    public func deleteKey(for wallet: Primitives.Wallet) async throws {
        switch wallet.type {
        case .view: break
        case .multicoin, .single, .privateKey:
            let password = try await getPassword()
            try await queue.asyncTask { [walletKeyStore] in
                do {
                    try walletKeyStore.deleteWallet(id: wallet.id, password: password)
                } catch let error as KeystoreError {
                    switch error {
                    case .unknownWalletInWalletCore, .unknownWalletIdInWalletCore, .unknownWalletInWalletCoreList, .invalidPrivateKey, .invalidPrivateKeyEncoding:
                        break
                    @unknown default:
                        throw error
                    }
                }
            }
        }
    }

    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain) async throws -> Data {
        let password = try await getPassword()
        return try await queue.asyncTask { [walletKeyStore] in
            try walletKeyStore.getPrivateKey(id: wallet.id, type: wallet.type, chain: chain, password: password)
        }
    }

    public func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) async throws -> String {
        let data = try await getPrivateKey(wallet: wallet, chain: chain)
        switch encoding {
        case .base58:
            return Base58.encodeNoCheck(data: data)
        case .hex:
            return data.hexString.append0x
        case .base32:
            throw KeystoreError.invalidPrivateKeyEncoding
        }
    }

    public func getMnemonic(wallet: Primitives.Wallet) async throws -> [String] {
        let password = try await getPassword()
        return try await queue.asyncTask { [walletKeyStore] in
            try walletKeyStore.getMnemonic(wallet: wallet, password: password)
        }
    }

    public func getPasswordAuthentication() throws -> KeystoreAuthentication {
        try keystorePassword.getAuthentication()
    }

    public func sign(hash: Data, wallet: Primitives.Wallet, chain: Chain) async throws -> Data {
        let password = try await getPassword()
        return try await queue.asyncTask { [walletKeyStore] in
            try walletKeyStore.sign(
                hash: hash,
                walletId: wallet.id,
                type: wallet.type,
                password: password,
                chain: chain
            )
        }
    }

    public func destroy() throws {
        try walletKeyStore.destroy()
    }

    @MainActor
    private func getPassword() throws -> String {
        try keystorePassword.getPassword()
    }

    @MainActor
    private func getOrCreatePassword(createPasswordIfNone: Bool) throws -> String {
        let password = try keystorePassword.getPassword()

        guard password.isEmpty, createPasswordIfNone else {
            return password
        }
        let newPassword = UUID().uuidString
        try keystorePassword.setPassword(newPassword, authentication: .none)
        return newPassword
    }
}

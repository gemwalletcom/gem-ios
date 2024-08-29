import Foundation
import WalletCore
import Primitives

public struct WalletKeyStore {
    private let keyStore: WalletCore.KeyStore
    private let directory: URL
    
    func createWallet() -> [String] {
        let wallet = HDWallet(strength: 128, passphrase: "")!
        return wallet.mnemonic.split(separator: " ").map{String($0)}
    }
    
    public init(directory: URL) {
        self.directory = directory
        self.keyStore = try! WalletCore.KeyStore(keyDirectory: directory)
    }
    
    public func importWallet(name: String, words: [String], chains: [Chain], password: String) throws -> Primitives.Wallet {
        let wallet = try keyStore.import(
            mnemonic: MnemonicFormatter.fromArray(words: words),
            name: name,
            encryptPassword: password,
            coins: []
        )
        return try addCoins(wallet: wallet, chains: chains, password: password)
    }

    public static func decodeKey(_ key: String, chain: Chain) throws -> PrivateKey {
        var data: Data?
        for encoding in chain.keyEncodingTypes {
            if data != nil {
                break
            }
            switch encoding {
            case .base58:
                if let decoded = Base58.decodeNoCheck(string: key), decoded.count % 32 == 0 {
                    data = decoded.prefix(32)
                }
            case .hex:
                data = Data(hexString: key)
            }
        }

        guard
            let data = data,
            PrivateKey.isValid(data: data, curve: chain.coinType.curve) == true,
            let key = PrivateKey(data: data)
        else {
            throw AnyError("Invalid private key format")
        }
        return key
    }

    public func importPrivateKey(name: String, key: String, chain: Chain, password: String) throws -> Primitives.Wallet {
        let privateKey = try Self.decodeKey(key, chain: chain)
        let wallet = try keyStore.import(privateKey: privateKey, name: name, password: password, coin: chain.coinType)

        let account = Primitives.Account(
            chain: chain,
            address: chain.coinType.deriveAddress(privateKey: privateKey),
            derivationPath: chain.coinType.derivationPath(), // not applicable
            extendedPublicKey: nil
        )

        return Primitives.Wallet(
            id: wallet.id,
            name: wallet.key.name,
            index: 0, 
            type: .privateKey,
            accounts: [account],
            order: 0,
            isPinned: false
        )
    }

    func addCoins(wallet: WalletCore.Wallet, chains: [Chain], password: String) throws -> Primitives.Wallet {
        let exclude = [Chain.solana]
        let coins = chains.filter { !exclude.contains($0) } .map { $0.coinType }.asSet().asArray()
        
        // Tricky wallet core implementation. By default is coins: [], it will create ethereum
        let _ = try keyStore.removeAccounts(wallet: wallet, coins: [.ethereum] + exclude.map { $0.coinType }, password: password)
        if chains.contains(.solana) {
            // By default solana derived a wrong derivation path, need to adjust use a new one
            let _ = try wallet.getAccount(password: password, coin: .solana, derivation: .solanaSolana)
        }
        
        let _ = try keyStore.addAccounts(wallet: wallet, coins: coins, password: password)

        let type: Primitives.WalletType = {
            if wallet.key.isMnemonic {
                return wallet.accounts.count == 1 ? .single : .multicoin
            }
            return .privateKey
        }()

        let accounts = chains.compactMap { chain in
            if let account = wallet.accounts.filter({ $0.coin == chain.coinType }).first {
                return account.mapToAccount(chain: chain)
            }
            return .none
        }
        return Wallet(
            id: wallet.id,
            name: wallet.key.name,
            index: 0,
            type: type,
            accounts: accounts,
            order: 0,
            isPinned: false
        )
    }
    
    func addChains(chains: [Chain], wallet: Primitives.Wallet, password: String) throws -> Primitives.Wallet {
        let wallet = try getWallet(id: wallet.id)
        return try addCoins(wallet: wallet, chains: chains, password: password)
    }
    
    private func getWallet(id: String) throws -> WalletCore.Wallet {
        guard let wallet = keyStore.wallets.filter({ $0.id == id}).first else {
            throw KeystoreError.unknownWalletInWalletCoreList
        }
        return wallet
    }
    
    func deleteWallet(id: String, password: String) throws {
        let wallet = try getWallet(id: id)
        try keyStore.delete(wallet: wallet, password: password)
    }
    
    func getPrivateKey(id: String, type: Primitives.WalletType, chain: Chain, password: String) throws -> Data {
        let wallet = try getWallet(id: id)
        switch type {
        case .multicoin, .single:
            guard
                let hdwallet = wallet.key.wallet(password: Data(password.utf8)) else {
                throw KeystoreError.unknownWalletInWalletCore
            }
            switch chain {
            case .solana:
                return hdwallet.getKeyDerivation(coin: chain.coinType, derivation: .solanaSolana).data
            default:
                return hdwallet.getKeyForCoin(coin: chain.coinType).data
            }
        case .privateKey:
            return try wallet.privateKey(password: password, coin: chain.coinType).data
        case .view:
            throw KeystoreError.invalidPrivateKey
        }
    }
    
    func getMnemonic(wallet: Primitives.Wallet, password: String) throws -> [String] {
        let wallet = try getWallet(id: wallet.id)
        guard
            let hdwallet = wallet.key.wallet(password: Data(password.utf8)) else {
            throw KeystoreError.unknownWalletInWalletCore
        }
        
        return MnemonicFormatter.toArray(string: hdwallet.mnemonic)
    }
    
    public func sign(message: SignMessage, walletId: String, password: String, chain: Chain) throws -> Data {
        let wallet = try getWallet(id: walletId)
        let key = try wallet.privateKey(password: password, coin: chain.coinType)
        guard var signature = key.sign(digest: message.hash, curve: chain.coinType.curve) else {
            throw AnyError("no data signed")
        }
        switch message.type {
        case .sign,
            .eip191,
            .eip712:
            signature[64] += 27
            return signature
        case .base58:
            return signature
        }
    }
    
    func destroy() throws {
        try keyStore.destroy()
    }
}

extension WalletCore.Wallet {
    var id: String {
        return key.identifier!
    }
}

extension WalletCore.Account {
    func mapToAccount(chain: Chain) -> Primitives.Account {
        return Account(chain: chain, address: address, derivationPath: derivationPath, extendedPublicKey: extendedPublicKey)
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import struct Formatters.MnemonicFormatter
import Foundation
import Primitives
@preconcurrency import WalletCore
import WalletCorePrimitives

public struct WalletKeyStore: Sendable {
    private let keyStore: WalletCore.KeyStore
    private let directory: URL

    func createWallet() -> [String] {
        let wallet = HDWallet(strength: 128, passphrase: "")!
        return wallet.mnemonic.split(separator: " ").map { String($0) }
    }

    public init(directory: URL) {
        self.directory = directory
        keyStore = try! WalletCore.KeyStore(keyDirectory: directory)
    }

    public func importWallet(name: String, words: [String], chains: [Chain], password: String, source: WalletSource) throws -> Primitives.Wallet {
        let wallet = try keyStore.import(
            mnemonic: MnemonicFormatter.fromArray(words: words),
            name: name,
            encryptPassword: password,
            coins: []
        )
        return try addCoins(wallet: wallet, existingChains: [], newChains: chains, password: password, source: source)
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
            case .base32:
                if let decoded = try? decodeBase32Key(string: key, chain: chain) {
                    data = decoded
                }
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

    static func decodeBase32Key(string: String, chain: Chain) throws -> Data {
        switch chain {
        case .stellar:
            // test against https://lab.stellar.org/account/create
            guard
                string.count == 56,
                string.hasPrefix("S"),
                let decoded = Base32.decode(string: string),
                decoded.count == 35,
                decoded[0] == 0x90 // Mainnet
            else {
                throw KeystoreError.invalidPrivateKeyEncoding
            }
            // 35-byte format: [1 version] + [32 payload] + [2 checksum/padding]
            return Data(decoded[1 ..< 33])

        default:
            throw KeystoreError.invalidPrivateKeyEncoding
        }
    }

    public func importPrivateKey(name: String, key: String, chain: Chain, password: String, source: WalletSource) throws -> Primitives.Wallet {
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
            isPinned: false,
            imageUrl: nil,
            source: source
        )
    }

    public func addCoins(wallet: WalletCore.Wallet, existingChains: [Chain], newChains: [Chain], password: String, source: WalletSource) throws -> Primitives.Wallet {
        let allChains = existingChains + newChains
        let exclude = [Chain.solana]
        let coins = allChains.filter { !exclude.contains($0) }.map { $0.coinType }.asSet().asArray()
        let existingCoinTypes = existingChains.map({ $0.coinType }).asSet()
        let newCoinTypes = newChains.map({ $0.coinType }).asSet()

        // Tricky wallet core implementation. By default is coins: [], it will create ethereum
        // if single chain, remove all to simplify
        if existingChains.isEmpty && newChains.count == 1 {
            let _ = try keyStore.removeAccounts(wallet: wallet, coins: [.ethereum] + exclude.map { $0.coinType }, password: password)
        }
        if newChains.contains(.solana) && !existingChains.contains(.solana) {
            // By default solana derived a wrong derivation path, need to adjust use a new one
            let _ = try wallet.getAccount(password: password, coin: .solana, derivation: .solanaSolana)
        }
        if newChains.isNotEmpty && newCoinTypes.subtracting(existingCoinTypes).isNotEmpty {
            let _ = try keyStore.addAccounts(wallet: wallet, coins: coins, password: password)
        }

        let type: Primitives.WalletType = {
            if wallet.key.isMnemonic {
                return wallet.accounts.count == 1 ? .single : .multicoin
            }
            return .privateKey
        }()

        let accounts = allChains.compactMap { chain in
            wallet.accounts.filter({ $0.coin == chain.coinType }).first?.mapToAccount(chain: chain)
        }

        return Wallet(
            id: wallet.id,
            name: wallet.key.name,
            index: 0,
            type: type,
            accounts: accounts,
            order: 0,
            isPinned: false,
            imageUrl: nil,
            source: source
        )
    }

    public func addChains(wallet: Primitives.Wallet, existingChains: [Chain], newChains: [Chain], password: String) throws -> Primitives.Wallet {
        try addCoins(
            wallet: try getWallet(id: wallet.id),
            existingChains: existingChains,
            newChains: newChains,
            password: password,
            source: wallet.source
        )
    }

    private func getWallet(id: String) throws -> WalletCore.Wallet {
        guard let wallet = keyStore.wallets.filter({ $0.id == id }).first else {
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
                let hdwallet = wallet.key.wallet(password: Data(password.utf8))
            else {
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
            let hdwallet = wallet.key.wallet(password: Data(password.utf8))
        else {
            throw KeystoreError.unknownWalletInWalletCore
        }

        return MnemonicFormatter.toArray(string: hdwallet.mnemonic)
    }

    public func sign(hash: Data, walletId: String, type: Primitives.WalletType, password: String, chain: Chain) throws -> Data {
        let key = try getPrivateKey(id: walletId, type: type, chain: chain, password: password)
        guard
            let privateKey = PrivateKey(data: key),
            let signature = privateKey.sign(digest: hash, curve: chain.coinType.curve)
        else {
            throw AnyError("no data signed")
        }
        return signature
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
        return Account(
            chain: chain,
            address: chain.shortAddress(address: address),
            derivationPath: derivationPath,
            extendedPublicKey: extendedPublicKey
        )
    }
}

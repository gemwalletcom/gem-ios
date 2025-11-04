// Copyright (c). Gem Wallet. All rights reserved.

import Keystore
import Primitives
import Testing
import WalletCore

final class WalletKeyStoreTests {
    // phantom
    private let testBase58Key = "4ha2npeRkDXipjgGJ3L5LhZ9TK9dRjP2yktydkFBhAzXj3N8ytpYyTS24kxcYGEefy4WKWRcog2zSPvpPZoGmxCC"
    let words = "panda eternal chronic student column crumble endorse cushion whisper space carpet pitch praise tribe audit wing boil firm pink umbrella senior venture crouch confirm"
    let password = "test"

    @Test
    func testImportPrivateKey() throws {
        let store = WalletKeyStore.mock()
        let wallet = try store.importPrivateKey(
            name: "test",
            key: testBase58Key,
            chain: .solana,
            password: "test",
            isCreated: false
        )

        #expect(wallet.type == .privateKey)
        #expect(wallet.accounts == [
            Primitives.Account(
                chain: .solana,
                address: "JSTURBrew3zGaJjtk7qcvd7gapeExX3GC7DiQBaCKzU",
                derivationPath: "m/44\'/501\'/0\'",
                extendedPublicKey: .none
            )
        ])
    }

    @Test
    func importSolanaWalletByKey() throws {
        let base58 = "DTJi5pMtSKZHdkLX4wxwvjGjf2xwXx1LSuuUZhugYWDV"
        let key = try WalletKeyStore.decodeKey(testBase58Key, chain: .solana)
        let address = CoinType.solana.deriveAddress(privateKey: key)

        #expect(address == "JSTURBrew3zGaJjtk7qcvd7gapeExX3GC7DiQBaCKzU")
        #expect(Base58.encodeNoCheck(data: key.data) == base58)

        let hex = "0x30df0ffc2b43717f4653c2a1e827e9dfb3d9364e019cc60092496cd4997d5d6e"
        let key2 = try WalletKeyStore.decodeKey(hex, chain: .ethereum)
        let address2 = CoinType.ethereum.deriveAddress(privateKey: key2)

        #expect(address2 == "0x4ce31c0b2114abe61Ac123E1E6254E961C18D10B")
    }

    @Test func importStellarSecretKey() throws {
        let wallet = HDWallet(mnemonic: words, passphrase: "")!
        let key = wallet.getKeyForCoin(coin: .stellar)

        #expect(key.data.hexString == "3d769e8a65b9002a470e9aecf2587ef848e2a0b483320e24c493a5913d594eb9")

        let string = "SA6XNHUKMW4QAKSHB2NOZ4SYP34ERYVAWSBTEDREYSJ2LEJ5LFHLTIRJ"
        let keyFromString = try WalletKeyStore.decodeKey(string, chain: .stellar)

        #expect(key.data.count == 32)
        #expect(keyFromString.data == key.data)

        let pubKey = keyFromString.getPublicKeyEd25519()
        let address = CoinType.stellar.deriveAddressFromPublicKey(publicKey: pubKey)

        #expect(address == "GADB4BDKTOE36L6QN2JLIPNNJ7EZPSY5BIVKWXLWYZLIPXNQWIRQQZKT")
    }
    
    @Test func addImportWallet() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(
            name: "",
            words: words.components(separatedBy: ", "),
            chains: [.bitcoin, .ethereum],
            password: password,
            isCreated: false
        )
        
        #expect(newWallet.accounts.map { $0.chain } == [.bitcoin, .ethereum])
    }
    
    @Test func addCoinsMany() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(name: "", words: words.components(separatedBy: ", "), chains: [], password: password, isCreated: false)
        
        let wallet = try store.addChains(
            wallet: newWallet,
            existingChains: [],
            newChains: [.ethereum, .bitcoin],
            password: password
        )
        
        #expect(wallet.accounts.map { $0.chain } == [.ethereum, .bitcoin])
    }
    
    @Test func addCoinsEmptyChain() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(name: "", words: words.components(separatedBy: ", "), chains: [], password: password, isCreated: false)
        
        let wallet = try store.addChains(wallet: newWallet, existingChains: [], newChains: [], password: password)
        
        #expect(wallet.accounts.isEmpty)
    }
    
    @Test func addCoinsSingleChain() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(name: "", words: words.components(separatedBy: ", "), chains: [], password: password, isCreated: false)
        
        let wallet = try store.addChains(
            wallet: newWallet,
            existingChains: [],
            newChains: [.algorand],
            password: password
        )
        
        #expect(wallet.accounts.map { $0.chain } == [.algorand])
    }
    
    @Test func addCoinsWhenSolana() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(name: "", words: words.components(separatedBy: ", "), chains: [], password: password, isCreated: false)
        
        let wallet = try store.addChains(wallet: newWallet, existingChains: [], newChains: [.solana], password: password)
        
        #expect(wallet.accounts.map { $0.chain } == [.solana])
        #expect(wallet.accounts.map { $0.address } == ["9fb52fTJpTzYqV4be7u31TxxFfzs9ub9RehwLYuxhP6C"])
    }
    
    @Test func addCoinsManyTries() async throws {
        let store = WalletKeyStore.mock()
        let newWallet = try store.importWallet(name: "", words: words.components(separatedBy: ", "), chains: [], password: password, isCreated: false)
        
        let wallet = try store.addChains(
            wallet: newWallet,
            existingChains: [],
            newChains: [.ethereum],
            password: password
        )
        
        #expect(wallet.accounts.map { $0.chain } == [.ethereum])
        
        let wallet2 = try store.addChains(
            wallet: newWallet,
            existingChains: [.bitcoin],
            newChains: [.ethereum],
            password: password
        )
        
        #expect(wallet2.accounts.map { $0.chain } == [.bitcoin, .ethereum])
    }
}

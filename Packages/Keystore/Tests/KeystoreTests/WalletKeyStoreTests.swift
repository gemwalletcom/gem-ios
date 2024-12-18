// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Keystore
import WalletCorePrimitives
import WalletCore
import Primitives

final class WalletKeyStoreTests {
    // phantom
    private let testBase58Key = "4ha2npeRkDXipjgGJ3L5LhZ9TK9dRjP2yktydkFBhAzXj3N8ytpYyTS24kxcYGEefy4WKWRcog2zSPvpPZoGmxCC"

    @Test
    func testImportPrivateKey() throws {
        let store = WalletKeyStore.make()
        let wallet = try store.importPrivateKey(
            name: "test",
            key: testBase58Key,
            chain: .solana,
            password: "test"
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
    func testImportSolanaWalletByKey() throws {
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
}

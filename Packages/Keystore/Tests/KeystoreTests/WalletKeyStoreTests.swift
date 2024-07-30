// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Keystore
import WalletCorePrimitives
import WalletCore
import Primitives

final class WalletKeyStoreTests: XCTestCase {

    // phantom
    private let testBase58Key = "4ha2npeRkDXipjgGJ3L5LhZ9TK9dRjP2yktydkFBhAzXj3N8ytpYyTS24kxcYGEefy4WKWRcog2zSPvpPZoGmxCC"

    func testImportPrivateKey() throws {
        let store = WalletKeyStore.make()
        let wallet = try store.importPrivateKey(
            name: "test",
            key: testBase58Key,
            chain: .solana,
            password: "test"
        )

        XCTAssertEqual(wallet.type, .privateKey)
        XCTAssertEqual(wallet.accounts, [
            Primitives.Account(
                chain: .solana,
                address: "JSTURBrew3zGaJjtk7qcvd7gapeExX3GC7DiQBaCKzU",
                derivationPath: "m/44\'/501\'/0\'",
                extendedPublicKey: .none
            )
        ])
    }

    func testImportSolanaWalletByKey() throws {
        let base58 = "DTJi5pMtSKZHdkLX4wxwvjGjf2xwXx1LSuuUZhugYWDV"
        let key = try WalletKeyStore.decodeKey(testBase58Key, chain: .solana)
        let address = CoinType.solana.deriveAddress(privateKey: key)

        XCTAssertEqual(address, "JSTURBrew3zGaJjtk7qcvd7gapeExX3GC7DiQBaCKzU")
        XCTAssertEqual(Base58.encodeNoCheck(data: key.data), base58)

        let hex = "0x30df0ffc2b43717f4653c2a1e827e9dfb3d9364e019cc60092496cd4997d5d6e"
        let key2 = try WalletKeyStore.decodeKey(hex, chain: .ethereum)
        let address2 = CoinType.ethereum.deriveAddress(privateKey: key2)

        XCTAssertEqual(address2, "0x4ce31c0b2114abe61Ac123E1E6254E961C18D10B")
    }
}

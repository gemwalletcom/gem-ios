// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import KeystoreTestKit
@testable import Keystore

struct WalletIdentifierTests {

    @Test
    func secretDeriveAddress() throws {
        let identifier = WalletIdentifier.secret(words: LocalKeystore.words)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .ethereum)
        #expect(address == "0x8f348F300873Fd5DA36950B2aC75a26584584feE")
    }

    @Test
    func privateKeyDeriveAddress() throws {
        let identifier = WalletIdentifier.privateKey(chain: .ethereum, key: LocalKeystore.privateKey)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .ethereum)
        #expect(address == LocalKeystore.address)
    }

    @Test
    func singleDeriveAddress() throws {
        let identifier = WalletIdentifier.single(chain: .bitcoin, words: LocalKeystore.words)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .bitcoin)
        #expect(address == LocalKeystore.bitcoinAddress)
    }

    @Test
    func addressDeriveAddress() throws {
        let identifier = WalletIdentifier.address(address: LocalKeystore.address, chain: .polygon)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .polygon)
        #expect(address == LocalKeystore.address)
    }
}

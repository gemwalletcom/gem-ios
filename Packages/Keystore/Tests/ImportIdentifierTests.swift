// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import KeystoreTestKit
@testable import Keystore

struct ImportIdentifierTests {

    @Test
    func phraseDeriveAddress() throws {
        let identifier = ImportIdentifier.phrase(words: LocalKeystore.words)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .ethereum)
        #expect(address == "0x8f348F300873Fd5DA36950B2aC75a26584584feE")
    }

    @Test
    func privateKeyDeriveAddress() throws {
        let identifier = ImportIdentifier.privateKey(chain: .ethereum, key: LocalKeystore.privateKey)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .ethereum)
        #expect(address == LocalKeystore.address)
    }

    @Test
    func singleDeriveAddress() throws {
        let identifier = ImportIdentifier.single(chain: .bitcoin, words: LocalKeystore.words)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .bitcoin)
        #expect(address == LocalKeystore.bitcoinAddress)
    }

    @Test
    func addressDeriveAddress() throws {
        let identifier = ImportIdentifier.address(address: LocalKeystore.address, chain: .polygon)
        let (chain, address) = try identifier.deriveAddress()

        #expect(chain == .polygon)
        #expect(address == LocalKeystore.address)
    }
}

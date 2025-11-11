// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Keystore
import KeystoreTestKit
import Store
import StoreTestKit
import Preferences
import PreferencesTestKit
import WalletServiceTestKit
@testable import WalletService

struct WalletServiceTests {

    @Test
    func importSecretPhraseDuplicateSameChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "First Wallet",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )

        let wallet2 = try await service.importWallet(
            name: "Second Wallet",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .aptos])
        )

        #expect(wallet1.id == wallet2.id)
        #expect(wallet1.type == .multicoin)
        #expect(wallet2.type == .multicoin)
    }

    @Test
    func importSecretPhraseNoDuplicateDifferentWords() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "First Wallet",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )

        let differentWords = service.createWallet()
        let wallet2 = try await service.importWallet(
            name: "Second Wallet",
            type: .phrase(words: differentWords, chains: [.ethereum])
        )

        #expect(wallet1.id != wallet2.id)
    }

    @Test
    func importSingleDuplicateSameChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "First Single",
            type: .single(words: LocalKeystore.words, chain: .bitcoin)
        )

        let wallet2 = try await service.importWallet(
            name: "Second Single",
            type: .single(words: LocalKeystore.words, chain: .bitcoin)
        )

        #expect(wallet1.id == wallet2.id)
        #expect(wallet1.type == .single)
        #expect(wallet2.type == .single)
    }

    @Test
    func importSingleNoDuplicateDifferentChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "BTC Single",
            type: .single(words: LocalKeystore.words, chain: .bitcoin)
        )

        let wallet2 = try await service.importWallet(
            name: "LTC Single",
            type: .single(words: LocalKeystore.words, chain: .litecoin)
        )

        #expect(wallet1.id != wallet2.id)
    }

    @Test
    func importPrivateKeyDuplicateSameChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "First Wallet",
            type: .privateKey(text: LocalKeystore.privateKey, chain: .ethereum)
        )

        let wallet2 = try await service.importWallet(
            name: "Second Wallet",
            type: .privateKey(text: LocalKeystore.privateKey, chain: .ethereum)
        )

        #expect(wallet1.id == wallet2.id)
        #expect(wallet1.type == .privateKey)
        #expect(wallet2.type == .privateKey)
    }

    @Test
    func importPrivateKeyNoDuplicateDifferentChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "ETH Wallet",
            type: .privateKey(text: LocalKeystore.privateKey, chain: .ethereum)
        )

        let wallet2 = try await service.importWallet(
            name: "BSC Wallet",
            type: .privateKey(text: LocalKeystore.privateKey, chain: .smartChain)
        )

        #expect(wallet1.id != wallet2.id)
    }

    @Test
    func importViewOnlyDuplicateSameChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "First View",
            type: .address(address: LocalKeystore.address, chain: .ethereum)
        )

        let wallet2 = try await service.importWallet(
            name: "Second View",
            type: .address(address: LocalKeystore.address, chain: .ethereum)
        )

        #expect(wallet1.id == wallet2.id)
        #expect(wallet1.type == .view)
        #expect(wallet2.type == .view)
    }

    @Test
    func importViewOnlyNoDuplicateDifferentChain() async throws {
        let service = WalletService.mock()

        let wallet1 = try await service.importWallet(
            name: "ETH View",
            type: .address(address: LocalKeystore.address, chain: .ethereum)
        )

        let wallet2 = try await service.importWallet(
            name: "Polygon View",
            type: .address(address: LocalKeystore.address, chain: .polygon)
        )

        #expect(wallet1.id != wallet2.id)
    }

    @Test
    func importTypeMatchingExact() async throws {
        let service = WalletService.mock()

        let mnemonicWallet = try await service.importWallet(
            name: "Mnemonic",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .aptos])
        )

        let privateKeyWallet = try await service.importWallet(
            name: "Private Key",
            type: .privateKey(text: LocalKeystore.privateKey, chain: .ethereum)
        )

        #expect(mnemonicWallet.id != privateKeyWallet.id)
        #expect(mnemonicWallet.type == .multicoin)
        #expect(privateKeyWallet.type == .privateKey)
    }
}

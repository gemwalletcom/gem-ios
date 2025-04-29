import Testing
import WalletServiceTestKit
import Keystore

@testable import WalletService

struct WalletServiceTests {

    @Test
    func testCreateWallet() async throws {
        let walletService = WalletService.mock()
        let words = walletService.createWallet()

        #expect(words.count == 12)
    }

    @Test
    func testImportWallet() throws {
        let service = WalletService.mock()
        let wallet = try service.importWallet(
            name: "Main",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        #expect(service.wallets.map(\.walletId) == [wallet.walletId])
        #expect(service.currentWaletId == wallet.walletId)
    }

    @Test
    func testDeleteWallet() throws {
        let service = WalletService.mock()

        let first = try service.importWallet(
            name: "First",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        let second = try service.importWallet(
            name: "Second",
            type: .phrase(words: LocalKeystore.words, chains: [.solana])
        )

        try service.delete(first)

        #expect(service.wallets.map(\.walletId) == [second.walletId])
        #expect(service.currentWaletId == second.walletId)

        try service.delete(second)

        #expect(service.currentWaletId == nil)
        #expect(service.wallets.isEmpty)
    }

    @Test
    func testPinWallet() throws {
        let service = WalletService.mock()
        let wallet = try service.importWallet(
            name: "Pin me",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )

        try service.pin(wallet: wallet)

        #expect(service.wallets.first?.isPinned == true)

        try service.unpin(wallet: wallet)

        #expect(service.wallets.first?.isPinned == false)
    }

    @Test
    func testWalletsSwapOrder() throws {
        let service = WalletService.mock()
        let walletA = try service.importWallet(
            name: "A",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        let walletB = try service.importWallet(
            name: "B",
            type: .phrase(words: LocalKeystore.words, chains: [.solana])
        )

        let orderBefore = service.wallets.map(\.order)
        try service.swapOrder(from: walletA.walletId, to: walletB.walletId)
        let orderAfter = service.wallets.map(\.order)

        #expect(orderBefore != orderAfter)
    }

    @Test
    func testRenameWallet() throws {
        let service = WalletService.mock()
        let wallet = try service.importWallet(
            name: "Old",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )

        try service.rename(walletId: wallet.walletId, newName: "New")

        #expect(service.wallets.first?.name == "New")
    }

    @Test
    func testSetupChains() throws {
        let service = WalletService.mock()
        let original = try service.importWallet(
            name: "Upgradable",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum, .algorand])
        )

        #expect(original.accounts.map(\.chain) == [.ethereum, .algorand])

        try service.setup(chains: [.ethereum, .algorand, .solana])

        let updated = service.wallets.first { $0.walletId == original.walletId }!

        #expect(updated.accounts.map(\.chain) == [.ethereum, .algorand, .solana])
        #expect(updated.type == .multicoin)
    }

    @Test
    func testGetMenemonic() throws {
        let service = WalletService.mock()
        let wallet = try service.importWallet(
            name: "Mnemonic",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )

        #expect(try service.getMnemonic(wallet: wallet) == LocalKeystore.words)
    }

    @Test
    func testGetPrivateKeys() throws {
        let service = WalletService.mock()
        let hex = "0xb9095df5360714a69bc86ca92f6191e60355f206909982a8409f7b8358cf41b0"

        let wallet = try service.importWallet(
            name: "PK Wallet",
            type: .privateKey(text: hex, chain: .solana)
        )

        let privateKey = try service.getPrivateKey(
            wallet: wallet,
            chain: .solana,
            encoding: .hex
        )

        #expect(privateKey == hex)
    }

    @Test
    func testNextWalletIndex() throws {
        let service = WalletService.mock()

        #expect(try service.nextWalletIndex() == 1)

        _ = try service.importWallet(
            name: "First",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        #expect(try service.nextWalletIndex() == 2)

        _ = try service.importWallet(
            name: "Second",
            type: .phrase(words: LocalKeystore.words, chains: [.solana])
        )

        #expect(try service.nextWalletIndex() == 3)
    }

    @Test
    func testSetCurrentByIndexAndId() throws {
        let service = WalletService.mock()

        _ = try service.importWallet(
            name: "One",
            type: .phrase(words: LocalKeystore.words, chains: [.ethereum])
        )
        let second = try service.importWallet(
            name: "Two",
            type: .phrase(words: LocalKeystore.words, chains: [.solana])
        )

        service.setCurrent(for: 1)

        #expect(service.currentWaletId != nil)
        #expect(service.wallets[0].walletId == service.currentWaletId)

        service.setCurrent(for: second.walletId)
        #expect(service.currentWaletId == second.walletId)
    }
}

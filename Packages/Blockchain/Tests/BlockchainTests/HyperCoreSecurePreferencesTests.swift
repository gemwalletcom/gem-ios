import Testing
import Foundation
import Preferences
import Primitives
import PrimitivesTestKit
import WalletCore
import BlockchainTestKit

@testable import Blockchain

struct HyperCoreSecurePreferencesTests {
    let wallet = Wallet.mock(accounts: [
        .mock(chain: .hyperCore, address: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F")
    ])
    let preferences = MockHyperCoreSecurePreferences()

    var walletAddress: String {
        wallet.accounts.first!.address
    }

    @Test
    func create() throws {
        let key = try preferences.create(walletAddress: walletAddress)

        #expect(key.address.hasPrefix("0x"))
        #expect(key.address.count == 42)
        #expect(key.privateKey.count == 32)
    }

    @Test
    func getNotExists() throws {
        #expect(try preferences.get(walletAddress: walletAddress) == nil)
    }

    @Test
    func createAndGetKey() throws {
        let created = try preferences.create(walletAddress: walletAddress)
        let key = try preferences.get(walletAddress: walletAddress)

        #expect(key?.address == created.address)
        #expect(key?.privateKey == created.privateKey)
    }

    @Test
    func delete() throws {
        _ = try preferences.create(walletAddress: walletAddress)
        try preferences.delete(walletAddress: walletAddress)

        #expect(try preferences.get(walletAddress: walletAddress) == nil)
    }

    @Test
    func differentWalletsDifferentKeys() throws {
        let wallet1 = Wallet.mock(accounts: [
            .mock(chain: .hyperCore, address: "0x8e215d06ea7ec1fdb4fc5fd21768f4b34ee92ef4")
        ])
        let wallet2 = Wallet.mock(accounts: [
            .mock(chain: .hyperCore, address: "0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5")
        ])

        let key1 = try preferences.create(walletAddress: wallet1.accounts.first!.address)
        let key2 = try preferences.create(walletAddress: wallet2.accounts.first!.address)

        #expect(key1.privateKey != key2.privateKey)
    }
}

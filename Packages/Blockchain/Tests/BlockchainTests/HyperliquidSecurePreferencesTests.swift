import Testing
import Foundation
import Preferences
import Primitives
import PrimitivesTestKit
import WalletCore

@testable import Blockchain
@testable import BlockchainTestKit

struct HyperliquidSecurePreferencesTests {
    let wallet = Wallet.mock(accounts: [
        .mock(chain: .hyperCore, address: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F")
    ])
    let preferences = HyperliquidSecurePreferences()
    
    var walletAddress: String {
        wallet.accounts.first!.address
    }

    @Test
    func createKey() throws {
        let key = try preferences.createKey(walletAddress: walletAddress)
        
        #expect(key.address.hasPrefix("0x"))
        #expect(key.address.count == 42) // Standard Ethereum address length
        #expect(key.privateKey.count == 32)
    }
    
    @Test
    func getKeyNotExists() throws {
        #expect(try preferences.getKey(walletAddress: walletAddress) == nil)
    }
    
    @Test
    func createAndGetKey() throws {
        let created = try preferences.createKey(walletAddress: walletAddress)
        let retrieved = try preferences.getKey(walletAddress: walletAddress)
        
        #expect(retrieved?.address == created.address)
        #expect(retrieved?.privateKey == created.privateKey)
    }
    
    @Test
    func deleteKey() throws {
        _ = try preferences.createKey(walletAddress: walletAddress)
        try preferences.deleteKey(walletAddress: walletAddress)
        
        #expect(try preferences.getKey(walletAddress: walletAddress) == nil)
    }
    
    @Test
    func differentWalletsDifferentKeys() throws {
        let wallet1 = Wallet.mock(accounts: [.mock(chain: .hyperCore, address: "0x8e215d06ea7ec1fdb4fc5fd21768f4b34ee92ef4")])
        let wallet2 = Wallet.mock(accounts: [.mock(chain: .hyperCore, address: "0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5")])
        
        let key1 = try preferences.createKey(walletAddress: wallet1.accounts.first!.address)
        let key2 = try preferences.createKey(walletAddress: wallet2.accounts.first!.address)
        
        #expect(key1.address != key2.address)
        #expect(key1.privateKey != key2.privateKey)
    }
}
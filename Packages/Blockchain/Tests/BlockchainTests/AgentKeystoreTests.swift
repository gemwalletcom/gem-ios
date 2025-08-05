import Testing
import Foundation
import Keychain
import Primitives
import PrimitivesTestKit
import KeychainTestKit
import WalletCore

@testable import Blockchain
@testable import BlockchainTestKit

struct AgentKeystoreTests {
    let wallet = Wallet.mock(accounts: [
        .mock(chain: .hyperCore, address: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F")
    ])
    let keystore = LocalAgentKeystore.mock(chain: .hyperCore)
    
    var walletAddress: String {
        wallet.accounts.first!.address
    }

    @Test
    func createAgent() throws {
        let agent = try keystore.createAgent(walletAddress: walletAddress)
        
        #expect(agent.address.hasPrefix("0x"))
        #expect(agent.address.count == 42) // Standard Ethereum address length
        #expect(agent.privateKey.count == 32)
    }
    
    @Test
    func getAgentNotExists() throws {
        #expect(try keystore.getAgent(walletAddress: walletAddress) == nil)
    }
    
    @Test
    func createAndGetAgent() throws {
        let created = try keystore.createAgent(walletAddress: walletAddress)
        let retrieved = try keystore.getAgent(walletAddress: walletAddress)
        
        #expect(retrieved?.address == created.address)
        #expect(retrieved?.privateKey == created.privateKey)
    }
    
    @Test
    func deleteAgent() throws {
        _ = try keystore.createAgent(walletAddress: walletAddress)
        try keystore.deleteAgent(walletAddress: walletAddress)
        
        #expect(try keystore.getAgent(walletAddress: walletAddress) == nil)
    }
    
    @Test
    func differentWalletsDifferentAgents() throws {
        let wallet1 = Wallet.mock(accounts: [.mock(chain: .hyperCore, address: "0x8e215d06ea7ec1fdb4fc5fd21768f4b34ee92ef4")])
        let wallet2 = Wallet.mock(accounts: [.mock(chain: .hyperCore, address: "0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5")])
        
        let agent1 = try keystore.createAgent(walletAddress: wallet1.accounts.first!.address)
        let agent2 = try keystore.createAgent(walletAddress: wallet2.accounts.first!.address)
        
        #expect(agent1.address != agent2.address)
        #expect(agent1.privateKey != agent2.privateKey)
    }
    
    @Test
    func mockAgentKeystore() throws {
        let mockAgent = AgentKey(
            address: "0x742d35Cc6634C0532925a3b844Bc9e7595f6FEDC",
            privateKey: try Data.from(hex: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318")
        )
        let mock = MockAgentKeystore(getAgentResult: mockAgent)
        
        #expect(try mock.getAgent(walletAddress: walletAddress) == mockAgent)
        #expect(try mock.createAgent(walletAddress: walletAddress).address == "0x123")
    }
}

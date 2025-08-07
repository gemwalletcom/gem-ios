// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import Blockchain
import Primitives
import KeychainTestKit

public extension LocalAgentKeystore {
    static func mock(
        chain: Chain = .hyperCore,
        keychain: Keychain = MockKeychain()
    ) -> LocalAgentKeystore {
        LocalAgentKeystore(
            config: AgentConfig(chain: chain),
            keychain: keychain
        )
    }
}

public struct MockAgentKeystore: AgentKeystore {
    public var getAgentResult: AgentKey?
    public var createAgentResult: AgentKey
    public var deleteAgentError: Error?
    
    public init(
        getAgentResult: AgentKey? = nil,
        createAgentResult: AgentKey = AgentKey(address: "0x123", privateKey: Data(repeating: 1, count: 32)),
        deleteAgentError: Error? = nil
    ) {
        self.getAgentResult = getAgentResult
        self.createAgentResult = createAgentResult
        self.deleteAgentError = deleteAgentError
    }
    
    public func getAgent(walletAddress: String) throws -> AgentKey? {
        getAgentResult
    }
    
    public func createAgent(walletAddress: String) throws -> AgentKey {
        createAgentResult
    }
    
    public func deleteAgent(walletAddress: String) throws {
        if let error = deleteAgentError {
            throw error
        }
    }
}
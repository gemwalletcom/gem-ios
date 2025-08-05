// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import Primitives
import WalletCore

public protocol AgentKeystore: Sendable {
    func getAgent(walletAddress: String) throws -> AgentKey?
    func createAgent(walletAddress: String) throws -> AgentKey
    func deleteAgent(walletAddress: String) throws
}

public struct LocalAgentKeystore: AgentKeystore {
    private let keychain: Keychain
    private let config: AgentConfig

    public init(config: AgentConfig, keychain: Keychain = KeychainDefault()) {
        self.config = config
        self.keychain = keychain
    }

    public func getAgent(walletAddress: String) throws -> AgentKey? {
        guard let privateKeyHex = try keychain.get(privateKey(walletAddress)),
              let address = try keychain.get(addressKey(walletAddress)) else {
            return nil
        }
        
        return AgentKey(address: address, privateKey: try Data.from(hex: privateKeyHex))
    }

    public func createAgent(walletAddress: String) throws -> AgentKey {
        let privateKey = try SecureRandom.generateKey()
        let address = config.chain.coinType.deriveAddress(privateKey: PrivateKey(data: privateKey)!)
        
        try keychain.set(privateKey.hexString, key: self.privateKey(walletAddress))
        try keychain.set(address, key: addressKey(walletAddress))
        
        return AgentKey(address: address, privateKey: privateKey)
    }

    public func deleteAgent(walletAddress: String) throws {
        try keychain.remove(addressKey(walletAddress))
        try keychain.remove(privateKey(walletAddress))
    }
    
    private func addressKey(_ walletAddress: String) -> String {
        "\(config.addressKeyPrefix)_\(walletAddress)"
    }
    
    private func privateKey(_ walletAddress: String) -> String {
        "\(config.privateKeyPrefix)_\(walletAddress)"
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences
import Primitives
import WalletCore

public struct HyperCoreSecurePreferences: Sendable {
    static private let namespace = "hyperliquid_agent"

    private let preferences: SecureNamespacedPreferences
    
    public init() {
        self.preferences = SecureNamespacedPreferences(namespace: Self.namespace)
    }
    
    public func get(walletAddress: String) throws -> HyperCorePreferences? {
        guard let privateKeyHex = try preferences.get(privateKeyKey(walletAddress)),
              let address = try preferences.get(addressKey(walletAddress)) else {
            return nil
        }
        
        return HyperCorePreferences(
            address: address,
            privateKey: try Data.from(hex: privateKeyHex)
        )
    }
    
    public func create(walletAddress: String) throws -> HyperCorePreferences {
        let privateKey = try SecureRandom.generateKey()
        let privateKeyWallet = PrivateKey(data: privateKey)!
        let address = Chain.hyperCore.coinType.deriveAddress(privateKey: privateKeyWallet)
        let key = HyperCorePreferences(address: address, privateKey: privateKey)
        
        try preferences.set(privateKey.hexString, key: privateKeyKey(walletAddress))
        try preferences.set(address, key: addressKey(walletAddress))
        
        return key
    }
    
    public func delete(walletAddress: String) throws {
        try preferences.remove(privateKeyKey(walletAddress))
        try preferences.remove(addressKey(walletAddress))
    }
    
    private func addressKey(_ walletAddress: String) -> String { "address_\(walletAddress)" }
    private func privateKeyKey(_ walletAddress: String) -> String { "private_key_\(walletAddress)" }
}

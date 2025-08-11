// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import Primitives
import WalletCore

public final class MockHyperliquidSecurePreferences: @unchecked Sendable {
    private var storage: [String: HyperliquidKey] = [:]
    
    public init() {}
    
    public func getKey(walletAddress: String) throws -> HyperliquidKey? {
        storage[walletAddress]
    }
    
    public func createKey(walletAddress: String) throws -> HyperliquidKey {
        let privateKey = try SecureRandom.generateKey()
        let privateKeyWallet = PrivateKey(data: privateKey)!
        let address = Chain.hyperCore.coinType.deriveAddress(privateKey: privateKeyWallet)
        let key = HyperliquidKey(address: address, privateKey: privateKey)
        
        storage[walletAddress] = key
        return key
    }
    
    public func deleteKey(walletAddress: String) throws {
        storage.removeValue(forKey: walletAddress)
    }
}
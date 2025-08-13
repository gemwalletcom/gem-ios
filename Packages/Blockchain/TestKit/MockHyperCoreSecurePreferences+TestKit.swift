// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import Primitives
import WalletCore

public final class MockHyperCoreSecurePreferences: @unchecked Sendable {
    private var storage: [String: HyperCorePreferences] = [:]
    
    public init() {}
    
    public func get(walletAddress: String) throws -> HyperCorePreferences? {
        storage[walletAddress]
    }
    
    public func create(walletAddress: String) throws -> HyperCorePreferences {
        let privateKey = try SecureRandom.generateKey()
        let privateKeyWallet = PrivateKey(data: privateKey)!
        let address = Chain.hyperCore.coinType.deriveAddress(privateKey: privateKeyWallet)
        let key = HyperCorePreferences(address: address, privateKey: privateKey)
        
        storage[walletAddress] = key
        return key
    }
    
    public func delete(walletAddress: String) throws {
        storage.removeValue(forKey: walletAddress)
    }
}

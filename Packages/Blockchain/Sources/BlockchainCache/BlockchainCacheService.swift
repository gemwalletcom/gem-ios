// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BlockchainCacheService: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let chain: Chain
    
    public init(
        chain: Chain,
        userDefaults: UserDefaults = .init(suiteName: "blockchain_cache")!
    ) {
        self.chain = chain
        self.userDefaults = userDefaults
    }
    
    public func getBool(address: String, key: String) -> Bool? {
        let key = cacheKey(address: address, key: key)
        guard userDefaults.object(forKey: key) != nil else { return nil }
        return userDefaults.bool(forKey: key)
    }
    
    public func setBool(_ value: Bool, address: String, key: String) {
        userDefaults.set(value, forKey: cacheKey(address: address, key: key))
    }
    
    private func cacheKey(address: String, key: String) -> String {
        "blockchain_\(chain.rawValue)_\(address.lowercased())_\(key)"
    }
}

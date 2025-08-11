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
    
    public func hasKey(_ address: String, key: String) -> Bool {
        let key = cacheKey(address: address, key: key)
        return userDefaults.object(forKey: key) != nil
    }
    
    public func getBool(address: String, key: String) -> Bool? {
        let key = cacheKey(address: address, key: key)
        guard userDefaults.object(forKey: key) != nil else { return nil }
        return userDefaults.bool(forKey: key)
    }
    
    public func setBool(_ value: Bool, address: String, key: String) {
        userDefaults.set(value, forKey: cacheKey(address: address, key: key))
    }

    public func getInt(address: String, key: String, ttl: TimeInterval? = nil) -> Int? {
        guard isValid(address: address, key: key, ttl: ttl) else { return nil }
        
        let key = cacheKey(address: address, key: key)
        guard userDefaults.object(forKey: key) != nil else { return nil }
        return userDefaults.integer(forKey: key)
    }
    
    public func setInt(_ value: Int, address: String, key: String, ttl: TimeInterval? = nil) {
        userDefaults.set(value, forKey: cacheKey(address: address, key: key))
        if ttl != nil {
            userDefaults.set(Int(Date().timeIntervalSince1970), forKey: cacheKeyTimestamp(address: address, key: key))
        }
    }
    
    private func isValid(address: String, key: String, ttl: TimeInterval?) -> Bool {
        guard let ttl = ttl else { return true }
        
        guard let timestamp = userDefaults.object(forKey: cacheKeyTimestamp(address: address, key: key)) as? Int else { return false }
        
        let currentTime = Int(Date().timeIntervalSince1970)
        return currentTime - timestamp <= Int(ttl)
    }
    
    private func cacheKey(address: String, key: String) -> String {
        "blockchain_\(chain.rawValue)_\(address.lowercased())_\(key)"
    }
    
    private func cacheKeyTimestamp(address: String, key: String) -> String {
        cacheKey(address: address, key: "\(key)_timestamp")
    }
}

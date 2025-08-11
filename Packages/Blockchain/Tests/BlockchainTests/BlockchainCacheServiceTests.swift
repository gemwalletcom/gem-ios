// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
@testable import Blockchain

struct BlockchainCacheServiceTests {
    let service = BlockchainCacheService(chain: .bitcoin, userDefaults: UserDefaults(suiteName: "test_cache")!)
    let address = "0x123"
    
    @Test
    func setAndGetInt() {
        service.setInt(42, address: address, key: "test_int")
        #expect(service.getInt(address: address, key: "test_int") == 42)
    }
    
    @Test
    func setAndGetBool() {
        service.setBool(true, address: address, key: "test_bool")
        #expect(service.getBool(address: address, key: "test_bool") == true)
    }
    
    @Test
    func intWithTTL() async throws {
        let key = "ttl_int_\(UUID().uuidString)"
        
        service.setInt(100, address: address, key: key, ttl: 1)
        #expect(service.getInt(address: address, key: key, ttl: 1) == 100)
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        #expect(service.getInt(address: address, key: key, ttl: 1) == nil)
    }
    
    @Test
    func ttlDoesNotAffectNormalGet() async throws {
        let key = "mixed_ttl_\(UUID().uuidString)"
        
        service.setInt(999, address: address, key: key, ttl: 1)
        #expect(service.getInt(address: address, key: key) == 999)
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        #expect(service.getInt(address: address, key: key, ttl: 1) == nil)
        #expect(service.getInt(address: address, key: key) == 999)
    }
}

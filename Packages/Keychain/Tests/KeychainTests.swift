// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import LocalAuthentication
@testable import Keychain

struct KeychainTests {
    private let keychain: Keychain = KeychainDefault()
    
    @Test
    func testBasicStringOperations() throws {
        let key = "testKey"
        let value = "testValue"

        try keychain.set(value, key: key)
        #expect(try keychain.get(key) == value)
        
        try keychain.remove(key)
        #expect(try keychain.get(key) == nil)
    }
    
    @Test
    func testDataOperations() throws {
        let key = "testDataKey"
        let value = "testDataValue".data(using: .utf8)!
        
        try keychain.set(value, key: key)
        #expect(try keychain.getData(key) == value)
        
        try keychain.remove(key)
        #expect(try keychain.getData(key) == nil)
    }
    
    @Test
    func testAccessibilityOptions() throws {
        let key = "testAccessibilityKey"
        let value = "testValue"
        
        let securedKeychain = keychain.accessibility(.whenUnlocked, authenticationPolicy: .userPresence)
        try securedKeychain.set(value, key: key)
        #expect(try securedKeychain.get(key) == value)
        
        try securedKeychain.remove(key)
        #expect(try securedKeychain.get(key) == nil)
    }
    
    @Test
    func testAuthenticationContext() throws {
        let key = "testAuthKey"
        let value = "testValue"
        let context = LAContext()
        
        let authKeychain = keychain.authenticationContext(context)
        try authKeychain.set(value, key: key)
        #expect(try authKeychain.get(key) == value)
        
        try authKeychain.remove(key)
        #expect(try authKeychain.get(key) == nil)
    }
    
    @Test
    func testSynchronizationOptions() throws {
        let key = "testSyncKey"
        let value = "testValue"
        
        try keychain.set(value, key: key, ignoringAttributeSynchronizable: true)
        #expect(try keychain.get(key, ignoringAttributeSynchronizable: true) == value)
        
        try keychain.remove(key)
        #expect(try keychain.get(key, ignoringAttributeSynchronizable: true) == nil)
    }
    
    @Test
    func testMultipleOperations() throws {
        let keys = ["key1", "key2", "key3"]
        let values = ["value1", "value2", "value3"]
        
        for (key, value) in zip(keys, values) {
            try keychain.set(value, key: key)
            #expect(try keychain.get(key) == value)
        }
        
        for key in keys {
            try keychain.remove(key)
            #expect(try keychain.get(key) == nil)
        }
    }
    
    @Test
    func testSetInvalidData() throws {
        let key = "invalidDataKey"
        let invalidData = Data([0xFF, 0xFF, 0xFF])
        
        #expect(throws: Status.conversionError) {
            try keychain.set(invalidData, key: key)
        }
    }
    
    @Test
    func testGetNonExistentKey() throws {
        let key = "nonExistentKey"
        #expect(try keychain.get(key) == nil)
    }
    
    @Test
    func testRemoveNonExistentKey() throws {
        let key = "nonExistentKey"
        try keychain.remove(key)
    }
} 

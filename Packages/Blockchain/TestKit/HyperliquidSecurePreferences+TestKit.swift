// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import Primitives

public struct MockHyperliquidSecurePreferences: Sendable {
    public var getKeyResult: HyperliquidKey?
    public var createKeyResult: HyperliquidKey
    public var deleteKeyError: Error?
    
    public init(
        getKeyResult: HyperliquidKey? = nil,
        createKeyResult: HyperliquidKey = HyperliquidKey(address: "0x123", privateKey: Data(repeating: 1, count: 32)),
        deleteKeyError: Error? = nil
    ) {
        self.getKeyResult = getKeyResult
        self.createKeyResult = createKeyResult
        self.deleteKeyError = deleteKeyError
    }
    
    public func getKey(walletAddress: String) throws -> HyperliquidKey? {
        getKeyResult
    }
    
    public func createKey(walletAddress: String) throws -> HyperliquidKey {
        createKeyResult
    }
    
    public func deleteKey(walletAddress: String) throws {
        if let error = deleteKeyError {
            throw error
        }
    }
}
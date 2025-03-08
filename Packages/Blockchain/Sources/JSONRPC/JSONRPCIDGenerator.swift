// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class JSONRPCIDGenerator: @unchecked Sendable {
    static let shared = JSONRPCIDGenerator()
    private var currentId = 0
    private let lock = NSLock()
    
    private init() {}
    
    public func nextId() -> Int {
        lock.lock()
        defer { lock.unlock() }
        currentId += 1
        return currentId
    }
}

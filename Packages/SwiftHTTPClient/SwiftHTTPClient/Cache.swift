// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: (value: Value, expiration: Date)] = [:]
    private let ttl: TimeInterval

    public init(ttl: TimeInterval) {
        self.ttl = ttl
    }

    public func set(_ key: Key, value: Value) {
        let expiration = Date().addingTimeInterval(ttl)
        storage[key] = (value, expiration)
    }

    public func get(_ key: Key) -> Value? {
        guard let entry = storage[key] else { return nil }
        if Date() > entry.expiration {
            storage.removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    public func remove(_ key: Key) {
        storage.removeValue(forKey: key)
    }

    public func clear() {
        storage.removeAll()
    }
}

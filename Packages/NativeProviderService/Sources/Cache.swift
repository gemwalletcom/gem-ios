// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

actor MemoryCache {
    
    private var map = [String: Data]()
    
    func set(key: String, value: Data, ttl: Duration) async {
        //TODO: Implement ttl check
        map[key] = value
    }

    func get(key: String) async -> Data? {
        map[key]
    }
}

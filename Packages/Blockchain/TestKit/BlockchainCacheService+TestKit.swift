// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@testable import Blockchain

public extension BlockchainCacheService {
    static func mock(
        chain: Chain = .bitcoin,
        userDefaults: UserDefaults = UserDefaults(suiteName: "test_cache")!
    ) -> BlockchainCacheService {
        userDefaults.removePersistentDomain(forName: "test_cache")
        return BlockchainCacheService(chain: chain, userDefaults: userDefaults)
    }
}
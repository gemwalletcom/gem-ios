// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

struct NameService {
    
    let provider: GemAPINameService
    
    init(
        provider: GemAPINameService = GemAPIService()
    ) {
        self.provider = provider
    }
    
    func getName(name: String, chain: String) async throws -> NameRecord {
        return try await provider
            .getName(name: name, chain: chain)
    }
}

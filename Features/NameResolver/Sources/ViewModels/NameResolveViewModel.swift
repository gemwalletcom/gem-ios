// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct NameRecordViewModel: Sendable {
    public let chain: Chain
    let nameService = NameService()

    public init(chain: Chain) {
        self.chain = chain
    }

    func canResolveName(name: String) -> Bool {
        let nameParts = name.split(separator: ".")
        guard nameParts.count >= 2 && nameParts.last?.count ?? 0 >= 1 else {
            return false
        }
        return true
    }
    
    func resolveName(name: String) async throws -> NameRecord {
        return try await nameService.provider
            .getName(name: name, chain: chain.rawValue)
    }
}

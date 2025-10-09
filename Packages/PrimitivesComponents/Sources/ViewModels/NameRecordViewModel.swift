// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct NameRecordViewModel: Sendable {
    public let chain: Chain
    public let nameService: any NameServiceable

    public init(
        chain: Chain,
        nameService: any NameServiceable
    ) {
        self.chain = chain
        self.nameService = nameService
    }

    public func canResolveName(name: String) -> Bool {
        nameService.canResolveName(name: name)
    }
    
    public func resolveName(name: String) async throws -> NameRecord {
        try await nameService.getName(name: name, chain: chain.rawValue)
    }
}
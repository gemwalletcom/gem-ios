// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AddTokenService {
    private let chainServiceFactory: ChainServiceFactory
    
    public init(
        chainServiceFactory: ChainServiceFactory
    ) {
        self.chainServiceFactory = chainServiceFactory
    }
    
    public func getTokenData(chain: Chain, tokenId: String) async throws -> Asset {
        let service = chainServiceFactory.service(for: chain)
        return try await service.getTokenData(tokenId: tokenId)
    }
}

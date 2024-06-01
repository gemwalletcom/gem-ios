// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AddTokenService {
    private let chainServiceFactory: ChainServiceFactory
    
    init(
        chainServiceFactory: ChainServiceFactory
    ) {
        self.chainServiceFactory = chainServiceFactory
    }
    
    func getTokenData(chain: Chain, tokenId: String) async throws -> Asset {
        let service = chainServiceFactory.service(for: chain)
        return try await service.getTokenData(tokenId: tokenId)
    }
}

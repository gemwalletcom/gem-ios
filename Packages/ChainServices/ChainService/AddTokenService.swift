// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AddTokenService: AddTokenServable, Sendable {
    private let chainServiceFactory: any ChainServiceFactorable

    public init(chainServiceFactory: any ChainServiceFactorable) {
        self.chainServiceFactory = chainServiceFactory
    }

    public func getTokenData(chain: Chain, tokenId: String) async throws -> Asset {
        try await chainServiceFactory.service(for: chain).getTokenData(tokenId: tokenId)
    }
}

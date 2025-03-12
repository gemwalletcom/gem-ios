// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI

public struct MarketService: Sendable {
    private let provider: any GemAPIMarketService
    
    public init(provider: any GemAPIMarketService = GemAPIService.shared) {
        self.provider = provider
    }
    
    public func getMarkets() async throws -> Markets {
        try await provider.getMarkets()
    }
}

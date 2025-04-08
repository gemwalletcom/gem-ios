// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPIPriceServiceMock: GemAPIPriceService {
    public init() {}
    public func getPrice(
        assetIds: [String],
        currency: String
    ) async throws -> [AssetPrice] {
        []
    }
}

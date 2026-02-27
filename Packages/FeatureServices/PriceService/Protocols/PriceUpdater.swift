// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PriceUpdater: Sendable {
    func addPrices(assetIds: [AssetId]) async throws
}

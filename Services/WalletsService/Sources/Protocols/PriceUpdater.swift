// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol PriceUpdater: Sendable {
    func updatePrices(assetIds: [AssetId]) async throws
    func clear() throws
}

extension PriceUpdater {
    public func clear() throws {
        fatalError("unplemented")
    }
}

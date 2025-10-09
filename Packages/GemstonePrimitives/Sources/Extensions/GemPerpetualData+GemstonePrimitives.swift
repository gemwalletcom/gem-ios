// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualData {
    public func map() throws -> PerpetualData {
        PerpetualData(
            perpetual: try perpetual.map(),
            asset: try asset.map(),
            metadata: metadata.map()
        )
    }
}
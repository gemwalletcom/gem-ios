// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualMetadata {
    static func mock(isPinned: Bool = false) -> PerpetualMetadata {
        PerpetualMetadata(isPinned: isPinned)
    }
}

public extension PerpetualData {
    static func mock(
        perpetual: Perpetual = .mock(),
        asset: Asset = .mock(),
        metadata: PerpetualMetadata = .mock()
    ) -> PerpetualData {
        PerpetualData(
            perpetual: perpetual,
            asset: asset,
            metadata: metadata
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit

public extension PerpetualPositionData {
    static func mock(
        perpetual: Perpetual = .mock(),
        asset: Asset = .mock(),
        position: PerpetualPosition = .mock()
    ) -> PerpetualPositionData {
        PerpetualPositionData(
            perpetual: perpetual,
            asset: asset,
            position: position
        )
    }
}

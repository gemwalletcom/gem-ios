// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualReduceData {
    static func mock(
        data: PerpetualConfirmData = .mock(),
        positionDirection: PerpetualDirection = .long
    ) -> PerpetualReduceData {
        PerpetualReduceData(
            data: data,
            positionDirection: positionDirection
        )
    }
}

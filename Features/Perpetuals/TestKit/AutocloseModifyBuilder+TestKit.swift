// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Perpetuals

public extension AutocloseModifyBuilder {
    static func mock(
        position: PerpetualPositionData = .mock()
    ) -> AutocloseModifyBuilder {
        AutocloseModifyBuilder(position: position)
    }
}

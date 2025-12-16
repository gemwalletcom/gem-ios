// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@testable import Perpetuals

extension AutocloseModifyBuilder {
    static func mock(
        direction: PerpetualDirection = .long,
        autocloseOrderType: PerpetualOrderType = .market
    ) -> AutocloseModifyBuilder {
        AutocloseModifyBuilder(direction: direction, autocloseOrderType: autocloseOrderType)
    }
}

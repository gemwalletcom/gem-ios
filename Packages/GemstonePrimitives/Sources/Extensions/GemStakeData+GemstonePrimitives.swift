// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemStakeData {
    public func map() -> StakeData {
        StakeData(
            data: data,
            to: to
        )
    }
}

extension StakeData {
    public func map() -> GemStakeData {
        GemStakeData(
            data: data,
            to: to
        )
    }
}

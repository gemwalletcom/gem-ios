// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapHeaderInput: Sendable {
    let from: AssetValuePrice
    let to: AssetValuePrice

    public init(from: AssetValuePrice, to: AssetValuePrice) {
        self.from = from
        self.to = to
    }
}

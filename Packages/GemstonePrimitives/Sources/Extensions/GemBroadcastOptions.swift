// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension GemBroadcastOptions {
    func map() -> BroadcastOptions {
        BroadcastOptions(skipPreflight: true)
    }
}

public extension BroadcastOptions {
    func map() -> GemBroadcastOptions {
        GemBroadcastOptions(
            skipPreflight: skipPreflight
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives

public extension Gemstone.BroadcastOptions {
    func map() -> Primitives.BroadcastOptions {
        BroadcastOptions(skipPreflight: skipPreflight, fromAddress: fromAddress)
    }
}

public extension Primitives.BroadcastOptions {
    func map() -> Gemstone.BroadcastOptions {
        Gemstone.BroadcastOptions(skipPreflight: skipPreflight, fromAddress: fromAddress)
    }
}

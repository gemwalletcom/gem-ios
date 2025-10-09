// Copyright (c). Gem Wallet. All rights reserved.

import Gemstone
import Primitives

extension Gemstone.BroadcastOptions {
    public func map() -> Primitives.BroadcastOptions {
        BroadcastOptions(skipPreflight: skipPreflight)
    }
}

extension Primitives.BroadcastOptions {
    public func map() -> Gemstone.BroadcastOptions {
        Gemstone.BroadcastOptions(skipPreflight: skipPreflight)
    }
}

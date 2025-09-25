// Copyright (c). Gem Wallet. All rights reserved.

public extension BroadcastOptions {
    init(skipPreflight: Bool) {
        self.skipPreflight = skipPreflight
        self.fromAddress = nil
    }
}

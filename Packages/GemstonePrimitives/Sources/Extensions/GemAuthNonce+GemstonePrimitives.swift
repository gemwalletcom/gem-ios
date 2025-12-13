// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension AuthNonce {
    public func map() -> GemAuthNonce {
        GemAuthNonce(nonce: nonce, timestamp: timestamp)
    }
}

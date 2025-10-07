// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Recipient {
    static func mock(
        name: String? = nil,
        address: String = "0x1234567890123456789012345678901234567890",
        memo: String? = nil
    ) -> Recipient {
        Recipient(
            name: name,
            address: address,
            memo: memo
        )
    }
}

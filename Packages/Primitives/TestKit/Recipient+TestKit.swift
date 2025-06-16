// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Recipient {
    static func mock(
        name: String? = nil,
        address: String = .empty,
        memo: String? = nil
    ) -> Recipient {
        Recipient(
            name: name,
            address: address,
            memo: memo
        )
    }
}

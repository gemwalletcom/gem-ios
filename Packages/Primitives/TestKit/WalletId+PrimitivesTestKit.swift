// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension WalletId {
    static func mock(
        id: String = ""
    ) -> WalletId {
        WalletId(id: id)
    }
}

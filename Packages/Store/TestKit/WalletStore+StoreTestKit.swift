// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import StoreKit

public extension WalletStore {
    static func mock(
        db: DB = .mock()
    ) -> WalletStore {
        WalletStore(db: db)
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension WalletStore {
    static func mock(
        db: DB = DB(path: "\(UUID().uuidString).sqlite")
    ) -> WalletStore {
        WalletStore(db: db)
    }
}

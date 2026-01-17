// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension InAppNotificationStore {
    static func mock(db: DB = .mock()) -> Self {
        InAppNotificationStore(db: db)
    }
}

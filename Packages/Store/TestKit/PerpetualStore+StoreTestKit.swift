// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

extension PerpetualStore {
    public static func mock() -> Self {
        Self(db: DB.mock())
    }
}
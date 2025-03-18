// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Device {
    static func mock() -> Device {
        Device(
            id: .empty,
            platform: .ios,
            platformStore: .appStore,
            token: .empty,
            locale: .empty,
            version: .empty,
            currency: .empty,
            isPushEnabled: true,
            isPriceAlertsEnabled: .none,
            subscriptionsVersion: 1
        )
    }
}

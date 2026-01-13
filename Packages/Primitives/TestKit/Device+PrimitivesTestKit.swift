// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Device {
    static func mock() -> Device {
        Device(
            id: .empty,
            platform: .ios,
            platformStore: .appStore,
            os: "iOS 26",
            model: "iPhone",
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

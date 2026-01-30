// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import Primitives
import PrimitivesTestKit

public extension SubscriptionChanges {
    static func mock(
        toAdd: [WalletSubscription] = [],
        toDelete: [WalletSubscription] = []
    ) -> SubscriptionChanges {
        SubscriptionChanges(
            toAdd: toAdd,
            toDelete: toDelete
        )
    }
}

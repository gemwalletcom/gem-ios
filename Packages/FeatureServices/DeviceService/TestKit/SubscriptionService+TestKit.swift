// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import GemAPI
import GemAPITestKit
import Store
import StoreTestKit

public extension SubscriptionService {
    static func mock(
        subscriptionProvider: any GemAPISubscriptionService = GemAPISubscriptionServiceMock(),
        walletStore: WalletStore = .mock()
    ) -> SubscriptionService {
        SubscriptionService(
            subscriptionProvider: subscriptionProvider,
            walletStore: walletStore
        )
    }
}

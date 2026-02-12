// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPISubscriptionServiceMock: GemAPISubscriptionService {
    public init() {}
    public func getSubscriptions() async throws -> [WalletSubscriptionChains] { [] }
    public func addSubscriptions(subscriptions: [WalletSubscription]) async throws {}
    public func deleteSubscriptions(subscriptions: [WalletSubscriptionChains]) async throws {}
}

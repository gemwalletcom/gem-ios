// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPISubscriptionServiceMock: GemAPISubscriptionService {
    public init() {}
    public func getSubscriptions(deviceId: String) async throws -> [WalletSubscriptionChains] { [] }
    public func addSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws {}
    public func deleteSubscriptions(deviceId: String, subscriptions: [WalletSubscription]) async throws {}
}

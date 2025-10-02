// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public struct DeviceObserverService: Sendable {
    private let deviceService: any DeviceServiceable
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver

    public init(
        deviceService: any DeviceServiceable,
        subscriptionsService: SubscriptionService,
        subscriptionsObserver: SubscriptionsObserver
    ) {
        self.deviceService = deviceService
        self.subscriptionsService = subscriptionsService
        self.subscriptionsObserver = subscriptionsObserver
    }

    public func startSubscriptionsObserver() async throws {
        for try await _ in subscriptionsObserver.observe().dropFirst() {
            subscriptionsService.incrementSubscriptionsVersion()
            try await deviceService.update()
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public struct DeviceObserverService: Sendable {
    private let deviceService: DeviceService
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver

    public init(
        deviceService: DeviceService,
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
            onNewDeviceChange()
        }
    }

    private func onNewDeviceChange() {
        Task.detached { [deviceService] in
            try await deviceService.update()
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public struct DeviceObserverService: Sendable {
    private let deviceSyncManager: DeviceSyncManager
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver

    public init(
        deviceSyncManager: DeviceSyncManager,
        subscriptionsService: SubscriptionService,
        subscriptionsObserver: SubscriptionsObserver
    ) {
        self.deviceSyncManager = deviceSyncManager
        self.subscriptionsService = subscriptionsService
        self.subscriptionsObserver = subscriptionsObserver
    }

    public func startSubscriptionsObserver() async throws {
        for try await _ in subscriptionsObserver.observe().dropFirst() {
            subscriptionsService.incrementSubscriptionsVersion()
            // Сигнализируем о необходимости обновления, не запуская его напрямую.
            await deviceSyncManager.setNeedsUpdate()
        }
    }
}

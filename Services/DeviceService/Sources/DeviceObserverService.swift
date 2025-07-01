// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public actor DeviceObserverService: Sendable {
    private let deviceService: DeviceService
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver
    
    private var updateTask: Task<Void, Error>? = nil

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
        updateTask = Task {
            defer { updateTask = nil }
            try await deviceService.update()
        }
    }

    public func waitIfUpdating() async throws {
        try await updateTask?.value
    }
}

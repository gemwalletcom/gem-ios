// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public actor DeviceObserverService {
    private let deviceService: any DeviceServiceable
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver

    private var authTokenTask: Task<Void, Never>?

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

    public func startAuthTokenRefresh() {
        guard authTokenTask == nil else { return }

        authTokenTask = Task { [deviceService] in
            try? await deviceService.updateAuthTokenIfNeeded()
            while !Task.isCancelled {
                try? await Task.sleep(for: DeviceService.authTokenRefreshInterval)
                try? await deviceService.updateAuthTokenIfNeeded()
            }
        }
    }

    public func stopAuthTokenRefresh() {
        authTokenTask?.cancel()
        authTokenTask = nil
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Combine

public final class DeviceObserverService {

    private let deviceService: DeviceService
    private let subscriptionsService: SubscriptionService
    private let subscriptionsObserver: SubscriptionsObserver

    private var subscriptionsObserverAnyCancellable: AnyCancellable?

    public init(
        deviceService: DeviceService,
        subscriptionsService: SubscriptionService,
        subscriptionsObserver: SubscriptionsObserver
    ) {
        self.deviceService = deviceService
        self.subscriptionsService = subscriptionsService
        self.subscriptionsObserver = subscriptionsObserver
    }

    public func startSubscriptionsObserver() {
        self.subscriptionsObserverAnyCancellable = subscriptionsObserver.observe().sink { [weak self] update in
            self?.onNewSubscriptionUpdate()
        }
    }

    private func onNewSubscriptionUpdate() {
        subscriptionsService.incrementSubscriptionsVersion()
        onNewDeviceChange()
    }

    private func onNewDeviceChange() {
        Task.detached { [deviceService] in
            try await deviceService.update()
        }
    }
}

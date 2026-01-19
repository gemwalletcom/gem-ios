// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import DeviceService
import Store
import WalletService

public struct InAppNotificationService: Sendable {
    private let apiService: GemAPINotificationService
    private let deviceService: DeviceServiceable
    private let walletService: WalletService
    private let store: InAppNotificationStore

    public init(
        apiService: GemAPINotificationService = GemAPIService.shared,
        deviceService: DeviceServiceable,
        walletService: WalletService,
        store: InAppNotificationStore
    ) {
        self.apiService = apiService
        self.deviceService = deviceService
        self.walletService = walletService
        self.store = store
    }

    public func update() async throws {
        let deviceId = try deviceService.getDeviceId()
        let notifications = try await apiService.getNotifications(deviceId: deviceId)
        let walletNotifications = notifications.compactMap { notification in
            walletService.walletId(walletIndex: nil, walletTypeId: notification.walletId).map { ($0, notification) }
        }
        try store.addNotifications(walletNotifications)
    }

    public func markNotificationsRead() async throws {
        let deviceId = try deviceService.getDeviceId()
        try await apiService.markNotificationsRead(deviceId: deviceId)
    }
}

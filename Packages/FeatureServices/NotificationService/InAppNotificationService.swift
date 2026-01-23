// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import DeviceService
import Store
import WalletService
import Preferences

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

    public func update(walletId: WalletId) async throws {
        let preferences = WalletPreferences(walletId: walletId)
        let deviceId = try deviceService.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)

        let notifications = try await apiService.getNotifications(
            deviceId: deviceId,
            fromTimestamp: preferences.notificationsTimestamp
        )
        try store.addNotifications(notifications)

        preferences.notificationsTimestamp = newTimestamp
    }

    public func markNotificationsRead() async throws {
        let deviceId = try deviceService.getDeviceId()
        try await apiService.markNotificationsRead(deviceId: deviceId)
    }
}

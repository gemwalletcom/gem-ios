// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import DeviceService
import Store

public struct InAppNotificationService: Sendable {
    private let apiService: GemAPINotificationService
    private let deviceService: DeviceServiceable
    private let store: InAppNotificationStore

    public init(
        apiService: GemAPINotificationService = GemAPIService.shared,
        deviceService: DeviceServiceable,
        store: InAppNotificationStore
    ) {
        self.apiService = apiService
        self.deviceService = deviceService
        self.store = store
    }

    public func update() async throws {
        let deviceId = try deviceService.getDeviceId()
        let notifications = try await apiService.getNotifications(deviceId: deviceId)
        try store.addNotifications(notifications)
    }

    public func markNotificationsRead() async throws {
        let deviceId = try deviceService.getDeviceId()
        try await apiService.markNotificationsRead(deviceId: deviceId)
    }
}

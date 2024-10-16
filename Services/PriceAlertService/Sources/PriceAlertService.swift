// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives
import NotificationService
import DeviceService

public actor PriceAlertService: Sendable {

    private let store: PriceAlertStore
    private let apiService: any GemAPIPriceAlertService
    private let deviceService: any DeviceServiceable
    private let preferences: Preferences
    private let pushNotificationService: PushNotificationEnablerService

    public init(
        store: PriceAlertStore,
        apiService: any GemAPIPriceAlertService = GemAPIService(),
        deviceService: any DeviceServiceable,
        preferences: Preferences
    ) {
        self.store = store
        self.apiService = apiService
        self.deviceService = deviceService
        self.preferences = preferences
        self.pushNotificationService = PushNotificationEnablerService(preferences: preferences)
    }

    var isPushNotificationsEnabled: Bool {
        preferences.isPushNotificationsEnabled
    }

    public func getPriceAlerts() throws -> [PriceAlert] {
        try store.getPriceAlerts()
    }

    @discardableResult
    public func requestPermissions() async throws -> Bool {
        try await pushNotificationService.requestPermissions()
    }

    public func deviceUpdate() async throws {
        try await deviceService.update()
    }

    public func updatePriceAlerts() async throws {
        let priceAlerts = try await getPriceAlerts()
        try store.addPriceAlerts(priceAlerts)
    }

    private func getPriceAlerts() async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: try await deviceService.getDeviceId())
    }

    public func addPriceAlert(assetId: String, autoEnable: Bool = false) async throws {
        if autoEnable {
            if !preferences.isPriceAlertsEnabled {
                preferences.isPriceAlertsEnabled = true
                try await deviceService.update()
            }
        }

        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none, priceDirection: .none)
        try store.addPriceAlerts([priceAlert])
        try await apiService.addPriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: [priceAlert])
    }

    public func deletePriceAlert(assetId: String) async throws {
        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none, priceDirection: .none)
        try store.deletePriceAlerts([priceAlert])
        try await apiService.deletePriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: [priceAlert])
    }
}

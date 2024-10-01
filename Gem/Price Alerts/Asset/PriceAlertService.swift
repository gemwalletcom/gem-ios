// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives

struct PriceAlertService {

    private let store: PriceAlertStore
    private let apiService: any GemAPIPriceAlertService
    private let deviceService: DeviceService
    private let preferences: Preferences
    private let securePreferences: SecurePreferences
    private let pushNotificationService = PushNotificationEnablerService()

    init(
        store: PriceAlertStore,
        apiService: any GemAPIPriceAlertService = GemAPIService(),
        deviceService: DeviceService,
        preferences: Preferences = Preferences.standard,
        securePreferences: SecurePreferences = SecurePreferences.standard
    ) {
        self.store = store
        self.apiService = apiService
        self.deviceService = deviceService
        self.preferences = preferences
        self.securePreferences = securePreferences
    }

    var isPushNotificationsEnabled: Bool {
        preferences.isPushNotificationsEnabled
    }

    func getPriceAlerts() throws -> [PriceAlert] {
        try store.getPriceAlerts()
    }

    @discardableResult
    func requestPermissions() async throws -> Bool {
        try await pushNotificationService.requestPermissions()
    }

    func deviceUpdate() async throws {
        try await deviceService.update()
    }

    func updatePriceAlerts() async throws {
        let priceAlerts = try await getPriceAlerts()
        try store.addPriceAlerts(priceAlerts)
    }

    private func getPriceAlerts() async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: securePreferences.getDeviceId())
    }

    func addPriceAlert(assetId: String, autoEnable: Bool = false) async throws {
        if autoEnable {
            if !preferences.isPriceAlertsEnabled {
                preferences.isPriceAlertsEnabled = true
                try await deviceService.update()
            }
        }

        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none, priceDirection: .none)
        try store.addPriceAlerts([priceAlert])
        try await apiService.addPriceAlerts(deviceId: securePreferences.getDeviceId(), priceAlerts: [priceAlert])
    }

    func deletePriceAlert(assetId: String) async throws {
        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none, priceDirection: .none)
        try store.deletePriceAlerts([priceAlert])
        try await apiService.deletePriceAlerts(deviceId: securePreferences.getDeviceId(), priceAlerts: [priceAlert])
    }
}

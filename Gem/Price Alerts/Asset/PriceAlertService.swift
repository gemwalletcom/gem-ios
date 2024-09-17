// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives

struct PriceAlertService {

    private let store: PriceAlertStore
    private let apiService: GemAPIPriceAlertService
    private let deviceService: DeviceService
    private let preferences: Preferences
    private let securePreferences: SecurePreferences

    init(
        store: PriceAlertStore,
        apiService: GemAPIPriceAlertService = GemAPIService(),
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

    func getPriceAlerts() async throws {
        let priceAlerts = try await apiService.getPriceAlerts(deviceId: securePreferences.getDeviceId())
        try store.addPriceAlerts(priceAlerts)
    }

    func addPriceAlert(assetId: String, enable: Bool) async throws {
        if !preferences.isPriceAlertsEnabled && enable {
            preferences.isPriceAlertsEnabled = true
            try await deviceService.update()
        }

        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none)
        try store.addPriceAlerts([priceAlert])
        try await apiService.addPriceAlerts(deviceId: securePreferences.getDeviceId(), priceAlerts: [priceAlert])
    }

    func deletePriceAlert(assetId: String) async throws {
        let priceAlert = PriceAlert(assetId: assetId, price: .none, pricePercentChange: .none)
        try store.deletePriceAlerts([priceAlert])
        try await apiService.deletePriceAlerts(deviceId: securePreferences.getDeviceId(), priceAlerts: [priceAlert])
    }
}

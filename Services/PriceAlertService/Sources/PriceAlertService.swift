// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives
import NotificationService
import DeviceService
import Preferences

public struct PriceAlertService: Sendable {

    private let store: PriceAlertStore
    private let apiService: any GemAPIPriceAlertService
    private let deviceService: any DeviceServiceable
    private let preferences: Preferences
    private let pushNotificationService: PushNotificationEnablerService

    public init(
        store: PriceAlertStore,
        apiService: any GemAPIPriceAlertService = GemAPIService(),
        deviceService: any DeviceServiceable,
        preferences: Preferences = .standard
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

    public func update() async throws {
        let remote = try await getPriceAlerts()
        let local = try store.getPriceAlerts()
        
        let changes = SyncValues.changes(primary: .local, local: local.asSet(), remote: remote.asSet())
        
        if !changes.delete.isEmpty {
            try await deletePriceAlert(assetIds: changes.delete.asArray().map { $0.id })
        }
        if !changes.missing.isEmpty {
            try await addPriceAlerts(priceAlerts: changes.missing.asArray())
        }
    }

    private func getPriceAlerts() async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: try await deviceService.getDeviceId())
    }
    
    public func addPriceAlert(for assetId: AssetId) async throws {
        let priceAlert = PriceAlert(
            assetId: assetId.identifier,
            price: .none,
            pricePercentChange: .none,
            priceDirection: .none
        )
        try store.addPriceAlerts([priceAlert])
        try await addPriceAlerts(priceAlerts: [priceAlert])
    }
    
    public func addPriceAlerts(priceAlerts: [PriceAlert]) async throws {
        try await apiService.addPriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: priceAlerts)
    }
    
    public func enablePriceAlerts() async throws {
        if !preferences.isPriceAlertsEnabled {
            preferences.isPriceAlertsEnabled = true
            try await deviceService.update()
        }
    }

    public func deletePriceAlert(assetIds: [String]) async throws {
        let priceAlerts = assetIds.map {
            PriceAlert(assetId: $0, price: .none, pricePercentChange: .none, priceDirection: .none)
        }
        try store.deletePriceAlerts(priceAlerts)
        try await apiService.deletePriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: priceAlerts)
    }
}

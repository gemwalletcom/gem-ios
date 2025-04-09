// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import GemAPI
import Primitives
import NotificationService
import PriceService
import DeviceService
import Preferences

public struct PriceAlertService: Sendable {

    private let store: PriceAlertStore
    private let apiService: any GemAPIPriceAlertService
    private let deviceService: any DeviceServiceable
    private let priceService: PriceService
    private let preferences: Preferences
    private let pushNotificationService: PushNotificationEnablerService

    public init(
        store: PriceAlertStore,
        apiService: any GemAPIPriceAlertService = GemAPIService(),
        deviceService: any DeviceServiceable,
        priceService: PriceService,
        preferences: Preferences = .standard
    ) {
        self.store = store
        self.apiService = apiService
        self.deviceService = deviceService
        self.priceService = priceService
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
        
        let changes = SyncValues.changes(primary: .remote, local: local.asSet(), remote: remote.asSet())
        
        if !changes.delete.isEmpty {
            try store.deletePriceAlerts(changes.delete.asArray())
        }
        if !changes.missing.isEmpty {
            try store.addPriceAlerts(changes.missing.asArray())
        }
    }

    private func getPriceAlerts() async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: try await deviceService.getDeviceId())
    }
    
    public func add(priceAlert: PriceAlert) async throws {
        try store.addPriceAlerts([priceAlert])
        try await add(priceAlerts: [priceAlert])
    }
    
    public func add(priceAlerts: [PriceAlert]) async throws {
        try await apiService.addPriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: priceAlerts)
    }
    
    public func enablePriceAlerts() async throws {
        if !preferences.isPriceAlertsEnabled {
            preferences.isPriceAlertsEnabled = true
            try await deviceService.update()
        }
    }

    public func delete(priceAlerts: [PriceAlert]) async throws {
        try store.deletePriceAlerts(priceAlerts)
        try await apiService.deletePriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: priceAlerts)
    }
    
    public func updatePrices(for currency: String) async throws   {
        let assetIds = try store.getPriceAlerts().map { $0.assetId }.unique()
        try await priceService.updatePrices(assetIds: assetIds, currency: currency)
    }
}

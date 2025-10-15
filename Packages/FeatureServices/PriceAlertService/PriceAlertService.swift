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
    private let preferences: Preferences
    private let pushNotificationService: PushNotificationEnablerService
    private let priceObserverService: PriceObserverService
    
    public init(
        store: PriceAlertStore,
        apiService: any GemAPIPriceAlertService = GemAPIService(),
        deviceService: any DeviceServiceable,
        priceObserverService: PriceObserverService,
        preferences: Preferences = .standard
    ) {
        self.store = store
        self.apiService = apiService
        self.deviceService = deviceService
        self.priceObserverService = priceObserverService
        self.preferences = preferences
        self.pushNotificationService = PushNotificationEnablerService(preferences: preferences)
    }

    var isPushNotificationsEnabled: Bool {
        preferences.isPushNotificationsEnabled
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
        
        try syncChanges(remote: remote, local: local)
    }
    
    public func update(assetId: String) async throws {
        let remote = try await getPriceAlerts(for: assetId)
        let local = try store.getPriceAlerts(for: assetId)
        
        try syncChanges(remote: remote, local: local)
    }
    
    private func syncChanges(remote: [PriceAlert], local: [PriceAlert]) throws {
        let changes = SyncDiff.calculate(
            primary: .remote,
            local: local.map { $0.id }.asSet(),
            remote: remote.map { $0.id }.asSet()
        )
        try store.diffPriceAlerts(
            deleteIds: changes.toDelete.asArray(),
            alerts: remote
        )
    }
    
    private func getPriceAlerts() async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: try deviceService.getDeviceId(), assetId: .none)
    }

    private func getPriceAlerts(for assetId: String) async throws -> [PriceAlert] {
        try await apiService.getPriceAlerts(deviceId: try deviceService.getDeviceId(), assetId: assetId)
    }

    public func add(priceAlert: PriceAlert) async throws {
        try store.addPriceAlerts([priceAlert])
        try await add(priceAlerts: [priceAlert])
        try await priceObserverService.addAssets(assets: [priceAlert.assetId])
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
        try store.deletePriceAlerts(priceAlerts.ids )
        try await apiService.deletePriceAlerts(deviceId: try deviceService.getDeviceId(), priceAlerts: priceAlerts)
    }
}

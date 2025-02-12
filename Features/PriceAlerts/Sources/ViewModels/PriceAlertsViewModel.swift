// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Localization
import PriceAlertService
import PriceService
import Preferences

@Observable
public final class PriceAlertsViewModel: Sendable {
    private let preferences: ObservablePreferences
    private let priceAlertService: PriceAlertService
    private let priceService: PriceService

    public init(
        preferences: ObservablePreferences = .default,
        priceAlertService: PriceAlertService,
        priceService: PriceService
    ) {
        self.preferences = preferences
        self.priceAlertService = priceAlertService
        self.priceService = priceService
    }

    var title: String { Localized.Settings.PriceAlerts.title }
    var enableTitle: String { Localized.Settings.enableValue("") }

    var request: PriceAlertsRequest { PriceAlertsRequest() }

    var isPriceAlertsEnabled: Bool {
        get {
            preferences.isPriceAlertsEnabled
        }
        set {
            preferences.isPriceAlertsEnabled = newValue
        }
    }
}

// MARK: - Business Logic

extension PriceAlertsViewModel {
    public func fetch() async {
        do {
            try await priceAlertService.update()

            // update prices
            let assetIds = try priceAlertService.getPriceAlerts().map { $0.id }
            try await priceService.updatePrices(assetIds: assetIds, currency: preferences.preferences.currency)

        } catch {
            NSLog("getPriceAlerts error: \(error)")
        }
    }

    func deletePriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.deletePriceAlert(assetIds: [assetId.identifier])
        } catch {
            NSLog("deletePriceAlert error: \(error)")
        }
    }

    func handleAlertsEnabled(enabled: Bool) async {
        if enabled {
            await updateNotifications()
        }
        await deviceUpdate()
    }

    private func addPriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.addPriceAlert(for: assetId)
        } catch {
            NSLog("addPriceAlert error: \(error)")
        }
    }

    private func updateNotifications() async {
        do {
            preferences.preferences.isPushNotificationsEnabled = try await requestPermissions()
        } catch {
            NSLog("pushesUpdate error: \(error)")
        }
    }

    private func deviceUpdate() async {
        do {
            try await priceAlertService.deviceUpdate()
        } catch {
            NSLog("deviceUpdate error: \(error)")
        }
    }

    private func requestPermissions() async throws -> Bool {
        try await priceAlertService.requestPermissions()
    }
}

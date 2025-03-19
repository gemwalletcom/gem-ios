// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Localization
import PriceAlertService
import PriceService
import Preferences
import PrimitivesComponents

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

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .priceAlerts)
    }

    func sections(for alerts: [PriceAlertData]) -> PriceAlertsSections {
        alerts
            .filter { $0.priceAlert.lastNotifiedAt == nil }
            .reduce(into: PriceAlertsSections(autoAlerts: [], manualAlerts: [])) { result, alert in
            if alert.priceAlert.type == .auto {
                result.autoAlerts.append(alert)
            } else if let index = result.manualAlerts.firstIndex(where: { $0.first?.asset == alert.asset }) {
                result.manualAlerts[index].append(alert)
            } else {
                result.manualAlerts.append([alert])
            }
        }
    }
}

// MARK: - Business Logic

extension PriceAlertsViewModel {
    public func fetch() async {
        do {
            try await priceAlertService.update()

            // update prices
            let assetIds = try priceAlertService.getPriceAlerts().map { $0.assetId }.unique()
            try await priceService.updatePrices(assetIds: assetIds, currency: preferences.preferences.currency)

        } catch {
            NSLog("getPriceAlerts error: \(error)")
        }
    }

    func deletePriceAlert(priceAlert: PriceAlert) async {
        do {
            try await priceAlertService.delete(priceAlerts: [priceAlert])
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
            try await priceAlertService.add(priceAlert: .default(for: assetId.identifier))
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

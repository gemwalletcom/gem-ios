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
    
    public init(
        preferences: ObservablePreferences = .default,
        priceAlertService: PriceAlertService
    ) {
        self.preferences = preferences
        self.priceAlertService = priceAlertService
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
            .reduce(into: PriceAlertsSections(autoAlerts: [], manualAlerts: [])) { result, alert in
                switch alert.priceAlert.type {
                case .auto:
                    result.autoAlerts.append(alert)
                case .price, .pricePercentChange:
                    guard alert.priceAlert.lastNotifiedAt == nil else {
                        return
                    }
                    if let index = result.manualAlerts.firstIndex(where: { $0.first?.asset == alert.asset }) {
                        result.manualAlerts[index].append(alert)
                    } else {
                        result.manualAlerts.append([alert])
                    }
                }
        }
    }
}

// MARK: - Business Logic

extension PriceAlertsViewModel {
    public func fetch() async {
        do {
            try await priceAlertService.update()
            try await priceAlertService.updatePrices(for: preferences.preferences.currency)

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
            try await priceAlertService
                .add(priceAlert: .default(for: assetId.identifier, currency: preferences.preferences.currency))
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

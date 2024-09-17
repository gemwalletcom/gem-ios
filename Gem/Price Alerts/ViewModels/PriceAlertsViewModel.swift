// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

struct PriceAlertsViewModel {

    let preferences: Preferences
    private let priceAlertService: PriceAlertService

    init(
        preferences: Preferences = Preferences.standard,
        priceAlertService: PriceAlertService
    ) {
        self.preferences = preferences
        self.priceAlertService = priceAlertService
    }

    var title: String {
        Localized.Settings.PriceAlerts.title
    }

    var enableTitle: String {
        Localized.Settings.enableValue("")
    }

    var request: PriceAlertsRequest {
        PriceAlertsRequest()
    }

    var isPriceAlertsEnabled: Bool {
        preferences.isPriceAlertsEnabled
    }

    func requestPermissions() async throws -> Bool {
        try await priceAlertService.requestPermissions()
    }

    func deviceUpdate() async throws {
        try await priceAlertService.deviceUpdate()
    }

    func fetch() async {
        do {
            try await priceAlertService.getPriceAlerts()
        } catch {
            NSLog("getPriceAlerts error: \(error)")
        }
    }

    func addPriceAlert(assetId: String) async {
        do {
            try await priceAlertService.addPriceAlert(assetId: assetId, autoEnable: false)
        } catch {
            NSLog("addPriceAlert error: \(error)")
        }
    }

    func deletePriceAlert(assetId: String) async {
        do {
            try await priceAlertService.deletePriceAlert(assetId: assetId)
        }catch {
            NSLog("deletePriceAlert error: \(error)")
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

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

    func addPriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.addPriceAlert(assetId: assetId.identifier, autoEnable: false)
        } catch {
            NSLog("addPriceAlert error: \(error)")
        }
    }

    func deletePriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.deletePriceAlert(assetId: assetId.identifier)
        }catch {
            NSLog("deletePriceAlert error: \(error)")
        }
    }
}

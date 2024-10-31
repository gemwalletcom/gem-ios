// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Localization
import PriceAlertService

struct PriceAlertsViewModel {

    let preferences: Preferences
    private let priceAlertService: PriceAlertService
    private let priceService: PriceService

    init(
        preferences: Preferences = Preferences.standard,
        priceAlertService: PriceAlertService,
        priceService: PriceService
    ) {
        self.preferences = preferences
        self.priceAlertService = priceAlertService
        self.priceService = priceService
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

    func onPriceAlertsEnabled(newValue: Bool) async {
        preferences.isPriceAlertsEnabled = newValue

        switch newValue {
        case true:
            Task {
                preferences.isPushNotificationsEnabled = try await requestPermissions()
                try await deviceUpdate()
            }
        case false:
            Task {
                try await deviceUpdate()
            }
        }
    }

    func requestPermissions() async throws -> Bool {
        try await priceAlertService.requestPermissions()
    }

    func deviceUpdate() async throws {
        try await priceAlertService.deviceUpdate()
    }

    func fetch() async {
        do {
            try await priceAlertService.update()

            // update prices
            let assetIds = try priceAlertService.getPriceAlerts().map { $0.id }
            try await priceService.updatePrices(assetIds: assetIds)

        } catch {
            NSLog("getPriceAlerts error: \(error)")
        }
    }

    func addPriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.addPriceAlert(for: assetId)
        } catch {
            NSLog("addPriceAlert error: \(error)")
        }
    }

    func deletePriceAlert(assetId: AssetId) async {
        do {
            try await priceAlertService.deletePriceAlert(assetIds: [assetId.identifier])
        }catch {
            NSLog("deletePriceAlert error: \(error)")
        }
    }
}

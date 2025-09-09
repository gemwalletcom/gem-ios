// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Localization
import PriceAlertService
import GRDB
import GRDBQuery
import PrimitivesComponents

@Observable
@MainActor
public final class AssetPriceAlertsViewModel: Sendable {
    let priceAlertService: PriceAlertService
    let walletId: WalletId
    let asset: Asset
    
    var request: PriceAlertsRequest
    var priceAlerts: [PriceAlertData] = []

    var isPresentingSetPriceAlert: Bool = false
    
    public init(
        priceAlertService: PriceAlertService,
        walletId: WalletId,
        asset: Asset
    ) {
        self.priceAlertService = priceAlertService
        self.walletId = walletId
        self.asset = asset
        self.request = PriceAlertsRequest(assetId: asset.id)
    }
    
    var title: String { Localized.Settings.PriceAlerts.title }
    
    var autoAlertModel: PriceAlertItemViewModel? {
        priceAlerts
            .first(where: { $0.priceAlert.type == .auto })
            .map { PriceAlertItemViewModel(data: $0) }
    }
    
    var alertsModel: [PriceAlertItemViewModel] {
        priceAlerts
            .filter { $0.priceAlert.shouldDisplay && $0.priceAlert.type != .auto }
            .map { PriceAlertItemViewModel(data: $0) }
    }
    
    var emptyContentModel: EmptyContentTypeViewModel? {
        guard alertsModel.isEmpty else { return nil }
        return EmptyContentTypeViewModel(type: .priceAlerts)
    }
}

// MARK: - Business Logic

extension AssetPriceAlertsViewModel {
    func fetch() async {
        do {
            try await priceAlertService.update()
        } catch {
            NSLog("fetch error: \(error)")
        }
    }
    
    func deletePriceAlert(priceAlert: PriceAlert) async {
        do {
            try await priceAlertService.delete(priceAlerts: [priceAlert])
        } catch {
            NSLog("deletePriceAlert error: \(error)")
        }
    }
    
    func onSelectSetPriceAlert() {
        isPresentingSetPriceAlert = true
    }
    
    func onSetPriceAlertComplete() {
        isPresentingSetPriceAlert = false
    }
}

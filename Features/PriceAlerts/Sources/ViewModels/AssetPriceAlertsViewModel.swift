// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Localization
import PriceAlertService
import GRDB
import GRDBQuery
import PrimitivesComponents
import Components
import Style

@Observable
@MainActor
public final class AssetPriceAlertsViewModel: Sendable {
    let priceAlertService: PriceAlertService
    let walletId: WalletId
    let asset: Asset
    
    var request: PriceAlertsRequest
    var priceAlerts: [PriceAlertData] = []

    var isPresentingSetPriceAlert: Bool = false
    var isPresentingToastMessage: ToastMessage?
    
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
            .sorted(using: [
                KeyPathComparator(\.priceAlert.price, order: .reverse),
                KeyPathComparator(\.priceAlert.priceDirection, order: .reverse),
                KeyPathComparator(\.priceAlert.pricePercentChange, order: .reverse)
            ])
            .map { PriceAlertItemViewModel(data: $0) }
    }
    
    var emptyContentModel: EmptyContentTypeViewModel? {
        guard alertsModel.isEmpty, autoAlertModel == nil else { return nil }
        return EmptyContentTypeViewModel(type: .priceAlerts)
    }
}

// MARK: - Business Logic

extension AssetPriceAlertsViewModel {
    func fetch() async {
        do {
            try await priceAlertService.update(assetId: asset.id.identifier)
        } catch {
            #debugLog("fetch error: \(error)")
        }
    }
    
    func deletePriceAlert(priceAlert: PriceAlert) async {
        do {
            try await priceAlertService.delete(priceAlerts: [priceAlert])
        } catch {
            #debugLog("deletePriceAlert error: \(error)")
        }
    }
    
    func onSelectSetPriceAlert() {
        isPresentingSetPriceAlert = true
    }
    
    func onSetPriceAlertComplete(message: String) {
        isPresentingSetPriceAlert = false
        isPresentingToastMessage = ToastMessage(title: message, image: SystemImage.bellFill)
    }
}

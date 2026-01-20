// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import Style
import Localization
import PrimitivesComponents
import PriceService
import Preferences
import PriceAlertService
import SwiftUI
import Formatters

@MainActor
@Observable
public final class ChartSceneViewModel {
    private let service: ChartService
    private let priceService: PriceService

    let walletId: WalletId
    let assetModel: AssetViewModel
    let priceAlertService: PriceAlertService

    private let preferences: Preferences = .standard

    var state: StateViewType<ChartValuesViewModel> = .loading
    var selectedPeriod: ChartPeriod {
        didSet {
            Task { await fetch() }
        }
    }

    var priceData: PriceData?
    var priceRequest: PriceRequest

    public var isPresentingSetPriceAlert: Binding<AssetId?>

    var title: String { assetModel.name }
    
    var priceAlertsViewModel: PriceAlertsViewModel { PriceAlertsViewModel(priceAlerts: priceData?.priceAlerts ?? []) }
    var showPriceAlerts: Bool { priceAlertsViewModel.hasPriceAlerts && isPriceAvailable }
    var isPriceAvailable: Bool { PriceViewModel(price: priceData?.price, currencyCode: preferences.currency).isPriceAvailable }

    public init(
        service: ChartService = ChartService(),
        priceService: PriceService,
        assetModel: AssetViewModel,
        priceAlertService: PriceAlertService,
        walletId: WalletId,
        currentPeriod: ChartPeriod = ChartValuesViewModel.defaultPeriod,
        isPresentingSetPriceAlert: Binding<AssetId?>
    ) {
        self.service = service
        self.priceService = priceService
        self.assetModel = assetModel
        self.priceAlertService = priceAlertService
        self.walletId = walletId
        self.selectedPeriod = currentPeriod
        self.priceRequest = PriceRequest(assetId: assetModel.asset.id)
        self.isPresentingSetPriceAlert = isPresentingSetPriceAlert
    }
    
    var priceDataModel: AssetDetailsInfoViewModel? {
        guard let priceData else { return nil }
        return AssetDetailsInfoViewModel(priceData: priceData)
    }
}

// MARK: - Business Logic

extension ChartSceneViewModel {
    public func fetch() async {
        state = .loading
        do {
            let values = try await service.getCharts(
                assetId: assetModel.asset.id,
                period: selectedPeriod
            )
            if let market = values.market {
                try priceService.updateMarketPrice(assetId: assetModel.asset.id, market: market, currency: preferences.currency)
            }
            let price = try priceService.getPrice(for: assetModel.asset.id)
            let rate = try priceService.getRate(currency: preferences.currency)
            
            var charts = values.prices.map {
                ChartDateValue(date: Date(timeIntervalSince1970: TimeInterval($0.timestamp)), value: Double($0.value) * rate)
            }

            if let price = price, let last = charts.last, price.updatedAt > last.date {
                charts.append(ChartDateValue(date: .now, value: price.price))
            }

            let chartValues = try ChartValues.from(charts: charts)
            let formatter = CurrencyFormatter(currencyCode: preferences.currency)
            let model = ChartValuesViewModel(
                period: selectedPeriod,
                price: price?.mapToPrice(),
                values: chartValues,
                formatter: formatter
            )
            state = .data(model)
        } catch {
            state = .error(error)
        }
    }

    public func onSelectSetPriceAlerts() {
        isPresentingSetPriceAlert.wrappedValue = assetModel.asset.id
    }
}

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

@MainActor
@Observable
public final class ChartsViewModel {
    private let service: ChartService
    private let priceService: PriceService
    private let assetModel: AssetViewModel

    private let preferences: Preferences = .standard

    let periods: [ChartSelection] = [
        ChartSelection(period: .hour, title: Localized.Charts.hour),
        ChartSelection(period: .day, title: Localized.Charts.day),
        ChartSelection(period: .week, title: Localized.Charts.week),
        ChartSelection(period: .month, title: Localized.Charts.month),
        ChartSelection(period: .year, title: Localized.Charts.year),
        ChartSelection(period: .all, title: Localized.Charts.all),
    ]

    var state: StateViewType<ChartValuesViewModel> = .loading
    var currentPeriod: ChartPeriod {
        didSet {
            Task { await fetch() }
        }
    }

    var priceRequest: PriceRequest {
        PriceRequest(assetId: assetModel.asset.id)
    }

    var title: String { assetModel.name }
    var emptyTitle: String { Localized.Common.notAvailable }
    var errorTitle: String { Localized.Errors.errorOccured }

    public init(
        service: ChartService = ChartService(),
        priceService: PriceService,
        assetModel: AssetViewModel,
        currentPeriod: ChartPeriod = ChartValuesViewModel.defaultPeriod
    ) {
        self.service = service
        self.priceService = priceService
        self.assetModel = assetModel
        self.currentPeriod = currentPeriod
    }
}

// MARK: - Business Logic

extension ChartsViewModel {
    public func fetch() async {
        state = .loading
        do {
            let values = try await service.getCharts(
                assetId: assetModel.asset.id,
                period: currentPeriod,
                currency: preferences.currency
            )
            if let price = values.price {
                try priceService.updatePrice(price: price.mapToAssetPrice(assetId: assetModel.asset.id.identifier))
            }
            if let market = values.market {
                try priceService.updateMarketPrice(assetId: assetModel.asset.id, market: market)
            }

            let price = try priceService.getPrice(for: assetModel.asset.id)
            var charts = values.prices.map {
                ChartDateValue(date: Date(timeIntervalSince1970: TimeInterval($0.timestamp)), value: Double($0.value))
            }
            if let price {
                charts.append(ChartDateValue(date: .now, value: price.price))
            }

            let chartValues = try ChartValues.from(charts: charts)
            let model = ChartValuesViewModel(period: currentPeriod, price: price?.mapToPrice(), values: chartValues)
            state = .data(model)
        } catch {
            state = .error(error)
        }
    }
}

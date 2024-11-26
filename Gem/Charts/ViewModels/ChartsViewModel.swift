// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store
import Gemstone
import Style
import Localization
import MarketInsight

class ChartsViewModel: ObservableObject {

    let service: ChartService
    let priceService: PriceService
    let assetModel: AssetViewModel
    let assetsService: AssetsService
    
    @Published var currentPeriod: ChartPeriod {
        didSet {
            Task { await updateCharts() }
        }
    }
    
    let periods: [ChartSelection] = [
        ChartSelection(period: .hour, title: Localized.Charts.hour),
        ChartSelection(period: .day, title: Localized.Charts.day),
        ChartSelection(period: .week, title: Localized.Charts.week),
        ChartSelection(period: .month, title: Localized.Charts.month),
        ChartSelection(period: .year, title: Localized.Charts.year),
        ChartSelection(period: .all, title: Localized.Charts.all),
    ]
    
    @Published var state: StateViewType<ChartValuesViewModel> = .loading
    
    private let preferences: Preferences = .standard

    var priceRequest: PriceRequest {
        return PriceRequest(assetId: assetModel.asset.id.identifier)
    }

    var title: String { assetModel.name }

    var emptyTitle: String { Localized.Common.notAvailable }
    var errorTitle: String { Localized.Errors.errorOccured }

    var headerTitleView: WalletBarViewViewModel {
        WalletBarViewViewModel(
            name: assetModel.name,
            image: assetModel.assetImage,
            showChevron: false
        )
    }
    
    init(
        service: ChartService = ChartService(),
        priceService: PriceService,
        assetsService: AssetsService,
        assetModel: AssetViewModel,
        currentPeriod: ChartPeriod = ChartValuesViewModel.defaultPeriod
    ) {
        self.service = service
        self.priceService = priceService
        self.assetsService = assetsService
        self.assetModel = assetModel
        self.currentPeriod = currentPeriod
    }
    
    var explorerStorage: ExplorerStorage {
        ExplorerStorage(preferences: preferences)
    }

    func updateCharts() async {
        DispatchQueue.main.async {
            self.state = .loading
        }
        do {
            let values = try await service.getCharts(
                assetId: assetModel.asset.id,
                period: currentPeriod,
                currency: preferences.currency
            )
            if let price = values.price {
                try priceService.priceStore
                    .updatePrice(price: price.mapToAssetPrice(assetId: assetModel.asset.id.identifier))
            }
            if let market = values.market {
                try priceService.priceStore.updateMarket(assetId: assetModel.asset.id.identifier, market: market)
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
            DispatchQueue.main.async {
                self.state = .loaded(model)
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error)
            }
        }
    }
}

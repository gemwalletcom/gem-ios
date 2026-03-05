// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Formatters
import PrimitivesComponents
import PriceService

@Observable
@MainActor
public final class WalletPortfolioSceneViewModel {
    private let assets: [AssetData]
    private let service: PortfolioService
    private let priceService: PriceService
    private let currencyCode: String
    private let currencyFormatter: CurrencyFormatter

    var state: StateViewType<[ChartDateValue]> = .loading
    var selectedPeriod: ChartPeriod = .week

    public init(
        assets: [AssetData],
        portfolioService: PortfolioService,
        priceService: PriceService,
        currencyCode: String
    ) {
        self.assets = assets
        self.service = portfolioService
        self.priceService = priceService
        self.currencyCode = currencyCode
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
    }

    var navigationTitle: String { "Portfolio" }

    var periods: [ChartPeriod] {
        [.day, .week, .month, .year, .all]
    }

    var chartState: StateViewType<ChartValuesViewModel> {
        switch state {
        case .loading: .loading
        case .noData: .noData
        case .error(let error): .error(error)
        case .data(let charts): chartModel(charts: charts).map { .data($0) } ?? .noData
        }
    }
}

// MARK: - Business Logic

extension WalletPortfolioSceneViewModel {
    func fetch() async {
        state = .loading
        do {
            let portfolioAssets = try await service.getPortfolioAssets(assets: assets, period: selectedPeriod)
            let rate = try priceService.getRate(currency: currencyCode)
            let charts = portfolioAssets.values.map {
                ChartDateValue(date: Date(timeIntervalSince1970: TimeInterval($0.timestamp)), value: Double($0.value) * rate)
            }
            state = charts.isEmpty ? .noData : .data(charts)
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - Private

extension WalletPortfolioSceneViewModel {
    private func chartModel(charts: [ChartDateValue]) -> ChartValuesViewModel? {
        .priceChange(charts: charts, period: selectedPeriod, formatter: currencyFormatter)
    }
}

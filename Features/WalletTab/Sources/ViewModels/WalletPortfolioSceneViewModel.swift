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
    private let allTimeViewModel: AllTimeValueViewModel

    var state: StateViewType<PortfolioAssets> = .loading
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
        self.allTimeViewModel = AllTimeValueViewModel(currency: currencyCode)
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
        case .data(let portfolio): chartModel(portfolio: portfolio).map { .data($0) } ?? .noData
        }
    }

    var allTimeValues: [ListItemModel] {
        guard case .data(let portfolio) = state else { return [] }
        return [
            portfolio.allTimeHigh.map { allTimeViewModel.allTimeHigh(chartValue: $0) },
            portfolio.allTimeLow.map { allTimeViewModel.allTimeLow(chartValue: $0) },
        ].compactMap { $0 }
    }
}

// MARK: - Business Logic

extension WalletPortfolioSceneViewModel {
    func fetch() async {
        state = .loading
        do {
            let result = try await service.getPortfolioAssets(assets: assets, period: selectedPeriod)
            state = result.values.isEmpty ? .noData : .data(result)
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - Private

extension WalletPortfolioSceneViewModel {
    private func chartModel(portfolio: PortfolioAssets) -> ChartValuesViewModel? {
        let rate = (try? priceService.getRate(currency: currencyCode)) ?? 1.0
        let charts = portfolio.values.map {
            ChartDateValue(date: Date(timeIntervalSince1970: TimeInterval($0.timestamp)), value: Double($0.value) * rate)
        }
        return .priceChange(charts: charts, period: selectedPeriod, formatter: currencyFormatter)
    }
}

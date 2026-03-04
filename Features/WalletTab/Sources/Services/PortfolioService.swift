// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import PriceService

struct PortfolioService: Sendable {
    private let chartService: ChartService
    private let priceService: PriceService
    private static let formatter = ValueFormatter(style: .full)

    init(
        chartService: ChartService = ChartService(),
        priceService: PriceService
    ) {
        self.chartService = chartService
        self.priceService = priceService
    }

    func getCharts(assets: [AssetData], period: ChartPeriod, currencyCode: String) async throws -> [ChartDateValue] {
        let rate = try priceService.getRate(currency: currencyCode)
        let assetCharts = try await fetchAssetCharts(assets: assets, period: period)
        return combine(assetCharts: assetCharts, rate: rate)
    }
}

// MARK: - Private

extension PortfolioService {
    private func fetchAssetCharts(assets: [AssetData], period: ChartPeriod) async throws -> [(balance: Double, prices: [ChartValue])] {
        try await withThrowingTaskGroup(of: (balance: Double, prices: [ChartValue])?.self) { group in
            for data in assets {
                let balance = (try? Self.formatter.double(from: data.balance.total, decimals: data.asset.decimals.asInt)) ?? .zero
                guard balance > .zero else { continue }

                group.addTask {
                    let charts = try await self.chartService.getCharts(assetId: data.asset.id, period: period)
                    guard charts.prices.isNotEmpty else { return nil }
                    return (balance: balance, prices: charts.prices)
                }
            }
            var results: [(balance: Double, prices: [ChartValue])] = []
            for try await item in group {
                if let item { results.append(item) }
            }
            return results
        }
    }

    private func combine(assetCharts: [(balance: Double, prices: [ChartValue])], rate: Double) -> [ChartDateValue] {
        guard let timeline = assetCharts.max(by: { $0.prices.count < $1.prices.count })?.prices else {
            return []
        }
        return timeline.map { point in
            let total = assetCharts.reduce(Double.zero) { sum, chart in
                let price = chart.prices
                    .min(by: { abs($0.timestamp - point.timestamp) < abs($1.timestamp - point.timestamp) })?
                    .value ?? .zero
                return sum + chart.balance * Double(price) * rate
            }
            return ChartDateValue(date: Date(timeIntervalSince1970: TimeInterval(point.timestamp)), value: total)
        }
    }
}

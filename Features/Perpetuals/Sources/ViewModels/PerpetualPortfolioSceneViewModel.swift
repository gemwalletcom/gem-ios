// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import Formatters
import PerpetualService
import PrimitivesComponents
import Localization

@Observable
@MainActor
public final class PerpetualPortfolioSceneViewModel {
    private let wallet: Wallet
    private let perpetualService: PerpetualServiceable
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)

    var state: StateViewType<PerpetualPortfolioChartData> = .loading
    var selectedPeriod: ChartPeriod = .day
    var selectedChartType: PortfolioChartType = .value

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
    }

    var navigationTitle: String { "Account" }

    var periods: [ChartPeriod] {
        guard case .data(let data) = state else { return [.day, .week, .month, .all] }
        return data.availablePeriods.isEmpty ? [.day, .week, .month, .all] : data.availablePeriods
    }

    var chartState: StateViewType<ChartValuesViewModel> {
        switch state {
        case .loading: .loading
        case .noData: .noData
        case .error(let error): .error(error)
        case .data(let data): chartModel(data: data).map { .data($0) } ?? .noData
        }
    }

    func chartTypeTitle(_ type: PortfolioChartType) -> String {
        switch type {
        case .value: "Value"
        case .pnl: "PnL"
        }
    }

    func fetch() async {
        state = .loading
        do {
            let data = try await perpetualService.portfolio(wallet: wallet)
            if !data.availablePeriods.contains(selectedPeriod), let first = data.availablePeriods.first {
                selectedPeriod = first
            }
            state = .data(data)
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - Private

extension PerpetualPortfolioSceneViewModel {
    private func chartModel(data: PerpetualPortfolioChartData) -> ChartValuesViewModel? {
        guard let timeframe = data.timeframeData(for: selectedPeriod) else {
            return nil
        }
        let charts: [ChartDateValue] = switch selectedChartType {
        case .value: timeframe.accountValueHistory
        case .pnl: timeframe.pnlHistory
        }
        guard let values = try? ChartValues.from(charts: charts), values.hasVariation else {
            return nil
        }
        let valueChange = values.lastValue - values.baseValue
        let price = Price(
            price: valueChange,
            priceChangePercentage24h: values.percentageChange(from: values.baseValue, to: values.lastValue),
            updatedAt: .now
        )
        return ChartValuesViewModel(
            period: selectedPeriod,
            price: price,
            values: values,
            lineColor: .blue,
            formatter: currencyFormatter,
            signed: true
        )
    }
}

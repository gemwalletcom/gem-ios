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

    var state: StateViewType<PerpetualPortfolio> = .loading {
        didSet {
            switch state {
            case .data(let data): portfolio = data
            case .error: portfolio = nil
            case .loading, .noData: break
            }
        }
    }
    var selectedPeriod: ChartPeriod = .day
    var selectedChartType: PortfolioChartType = .value

    private var portfolio: PerpetualPortfolio?

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
    }

    var navigationTitle: String { Localized.Perpetuals.title }
    var infoSectionTitle: String { Localized.Common.info }

    var periods: [ChartPeriod] {
        guard let periods = portfolio?.availablePeriods, !periods.isEmpty else {
            return [.day, .week, .month, .all]
        }
        return periods
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
        case .value: Localized.Perpetual.value
        case .pnl: Localized.Perpetual.pnl
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

// MARK: - Stats

extension PerpetualPortfolioSceneViewModel {
    var unrealizedPnlTitle: String { Localized.Perpetual.unrealizedPnl }
    var unrealizedPnlValue: TextValue { TextValue(text: unrealizedPnlModel.text ?? "-", style: unrealizedPnlModel.textStyle) }

    var accountLeverageTitle: String { Localized.Perpetual.accountLeverage }
    var accountLeverageText: String { portfolio?.accountSummary.map { String(format: "%.2fx", $0.accountLeverage) } ?? "-" }

    var marginUsageTitle: String { Localized.Perpetual.marginUsage }
    var marginUsageText: String { portfolio?.accountSummary.map { CurrencyFormatter.percentSignLess.string($0.marginUsage * 100) } ?? "-" }

    var allTimePnlTitle: String { Localized.Perpetual.allTimePnl }
    var allTimePnlValue: TextValue { TextValue(text: allTimePnlModel.text ?? "-", style: allTimePnlModel.textStyle) }

    var volumeTitle: String { Localized.Perpetual.volume }
    var volumeText: String { portfolio.map { currencyFormatter.string($0.allTime?.volume ?? 0) } ?? "-" }
}

// MARK: - Private

extension PerpetualPortfolioSceneViewModel {
    private var unrealizedPnlModel: PriceChangeViewModel { priceChangeModel(value: portfolio?.accountSummary?.unrealizedPnl) }
    private var allTimePnlModel: PriceChangeViewModel { priceChangeModel(value: portfolio?.allTime?.pnlHistory.last?.value) }

    private func priceChangeModel(value: Double?) -> PriceChangeViewModel {
        PriceChangeViewModel(value: value, currencyFormatter: currencyFormatter)
    }

    private func chartModel(data: PerpetualPortfolio) -> ChartValuesViewModel? {
        guard let timeframe = data.timeframeData(for: selectedPeriod) else {
            return nil
        }
        let dataPoints: [PerpetualPortfolioDataPoint] = switch selectedChartType {
        case .value: timeframe.accountValueHistory
        case .pnl: timeframe.pnlHistory
        }
        let charts = dataPoints.map { ChartDateValue(date: $0.date, value: $0.value) }
        guard let values = try? ChartValues.from(charts: charts), values.hasVariation else {
            return nil
        }
        let valueChange = values.lastValue - values.firstValue
        let price = Price(
            price: valueChange,
            priceChangePercentage24h: values.percentageChange(from: values.firstValue, to: values.lastValue),
            updatedAt: .now
        )
        return ChartValuesViewModel(
            period: selectedPeriod,
            price: price,
            values: values,
            lineColor: Colors.blue,
            formatter: currencyFormatter,
            type: .priceChange
        )
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Formatters
import Foundation
import Primitives
import Style
import SwiftUI

internal import Charts

public struct ChartValuesViewModel: Sendable {
    public let period: ChartPeriod
    public let price: Price?
    public let values: ChartValues
    public let lineColor: Color
    public let formatter: CurrencyFormatter
    public let type: ChartValueType

    public static let defaultPeriod = ChartPeriod.day

    public init(
        period: ChartPeriod,
        price: Price?,
        values: ChartValues,
        lineColor: Color = Colors.blue,
        formatter: CurrencyFormatter,
        type: ChartValueType = .price
    ) {
        self.period = period
        self.price = price
        self.values = values
        self.lineColor = lineColor
        self.formatter = formatter
        self.type = type
    }

    var charts: [ChartDateValue] { values.charts }
    var lowerBoundValueText: String { formatter.string(values.lowerBoundValue) }
    var upperBoundValueText: String { formatter.string(values.upperBoundValue) }

    var chartPriceViewModel: ChartPriceViewModel? {
        guard let price else { return nil }
        let priceChangePercentage = period == Self.defaultPeriod
            ? price.priceChangePercentage24h
            : PriceChangeCalculator.calculate(.percentage(from: values.baseValue, to: price.price))
        return ChartPriceViewModel(period: period, date: nil, price: price.price, priceChangePercentage: priceChangePercentage, formatter: formatter, type: type)
    }

    func priceViewModel(for element: ChartDateValue) -> ChartPriceViewModel {
        let priceChangePercentage = PriceChangeCalculator.calculate(.percentage(from: values.baseValue, to: element.value))
        return ChartPriceViewModel(period: period, date: element.date, price: element.value, priceChangePercentage: priceChangePercentage, formatter: formatter, type: type)
    }
}

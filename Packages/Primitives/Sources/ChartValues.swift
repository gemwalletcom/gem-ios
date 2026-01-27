// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ChartValues: Sendable {
    public let charts: [ChartDateValue]

    public let lowerBoundValue: Double
    public let upperBoundValue: Double

    public let lowerBoundDate: Date
    public let upperBoundDate: Date

    init(
        charts: [ChartDateValue],
        lowerBoundValue: Double,
        upperBoundValue: Double,
        lowerBoundDate: Date,
        upperBoundDate: Date
    ) {
        self.charts = charts
        self.lowerBoundValue = lowerBoundValue
        self.upperBoundValue = upperBoundValue
        self.lowerBoundDate = lowerBoundDate
        self.upperBoundDate = upperBoundDate
    }

    public static func from(charts: [ChartDateValue]) throws -> ChartValues {
        let values = charts.map { $0.value }
        let dates = charts.map { $0.date }
        guard let lowerBoundValue = values.min(),
              let upperBoundValue = values.max(),
              let lowerBoundDateIndex = values.firstIndex(of: lowerBoundValue),
              let upperBoundDateIndex = values.firstIndex(of: upperBoundValue) else {
            throw AnyError("not able to calculate lower and upper bound")
        }

        return ChartValues(
            charts: charts,
            lowerBoundValue: lowerBoundValue,
            upperBoundValue: upperBoundValue,
            lowerBoundDate: dates[lowerBoundDateIndex],
            upperBoundDate: dates[upperBoundDateIndex]
        )
    }

    public var yScale: [Double] {
        let range = upperBoundValue - lowerBoundValue
        let padding = range * 0.05
        return [lowerBoundValue - padding, upperBoundValue + padding]
    }
    public var xScale: [Date] {
        guard let first = charts.first?.date, let last = charts.last?.date else { return [] }
        let padding = last.timeIntervalSince(first) * 0.02
        return [first, last.addingTimeInterval(padding)]
    }
    public var hasVariation: Bool { lowerBoundValue != upperBoundValue }

    public var firstValue: Double { charts.first?.value ?? 0 }
    public var lastValue: Double { charts.last?.value ?? 0 }
    public var firstNonZeroValue: Double? { charts.first(where: { $0.value != 0 })?.value }
    public var baseValue: Double { firstNonZeroValue ?? firstValue }

    public func percentageChange(from base: Double, to value: Double) -> Double {
        base == 0 ? 0 : (value - base) / base * 100
    }
}

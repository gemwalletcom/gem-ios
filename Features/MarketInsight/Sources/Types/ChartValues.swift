// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ChartValues {
    public let charts: [ChartDateValue]

    public let lowerBoundValue: Double
    public let upperBoundValue: Double

    public let lowerBoundDate: Date
    public let upperBoundDate: Date

    public init(
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


    public var yScale: [Double] {
        return [lowerBoundValue, upperBoundValue]
    }
    
    public var xScale: [Date] {
        return [lowerBoundDate, upperBoundDate]
    }
    
    public var firstValue: Double {
        return charts.first?.value ?? 0
    }

    public  static func from(charts: [ChartDateValue]) throws -> ChartValues {
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

    public func priceChange(base: Double, price: Double) -> (price: Double, priceChange: Double) {
        return (price, (price - base) / base * 100)
    }
}

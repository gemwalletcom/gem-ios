// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ChartDateValue {
    let date: Date
    let value: Double
}

struct ChartValues {
    let charts: [ChartDateValue]
    
    let lowerBoundValue: Double
    let upperBoundValue: Double
    
    let lowerBoundDate: Date
    let upperBoundDate: Date
    
    var yScale: [Double] {
        return [lowerBoundValue, upperBoundValue]
    }
    
    var xScale: [Date] {
        return [lowerBoundDate, upperBoundDate]
    }
    
    var firstValue: Double {
        return charts.first?.value ?? 0
    }

    static func from(charts: [ChartDateValue]) throws -> ChartValues {
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

    func priceChange(base: Double, price: Double) -> (price: Double, priceChange: Double) {
        return (price, (price - base) / base * 100)
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ChartBounds {
    static let desiredTickCount = 5

    let minPrice: Double
    let maxPrice: Double
    let visibleLines: [ChartLineViewModel]

    init(candles: [ChartCandleStick], lines: [ChartLineViewModel]) {
        let candleMin = candles.map(\.low).min() ?? 0
        let candleMax = candles.map(\.high).max() ?? 1
        let candleRange = candleMax - candleMin

        let visibleLines = lines.filter {
            $0.price >= candleMin - candleRange * 0.5 && $0.price <= candleMax + candleRange * 0.5
        }

        let overlayMin = visibleLines.map(\.price).min() ?? candleMin
        let overlayMax = visibleLines.map(\.price).max() ?? candleMax
        let priceRange = max(candleMax, overlayMax) - min(candleMin, overlayMin)
        let padding = priceRange * 0.05

        self.minPrice = min(candleMin, overlayMin) - padding
        self.maxPrice = max(candleMax, overlayMax) + padding
        self.visibleLines = visibleLines.sorted { $0.price < $1.price }
    }
    
    var axisStride: Double {
        (maxPrice - minPrice) / Double(Self.desiredTickCount)
    }

    var axisFractionLength: Int {
        switch axisStride {
        case _ where axisStride >= 1: 0
        case _ where axisStride >= 0.1: 1
        case _ where axisStride >= 0.01: 2
        case _ where axisStride >= 0.001: 3
        case _ where axisStride >= 0.0001: 4
        default: 5
        }
    }

    var axisFormat: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(axisFractionLength))
    }
}

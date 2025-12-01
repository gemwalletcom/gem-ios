// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

struct ChartBounds {
    let minPrice: Double
    let maxPrice: Double
    let visibleLines: [ChartLineViewModel]

    init(candles: [ChartCandleStick], lines: [ChartLineViewModel]) {
        let candleMin = candles.map { min($0.low, $0.open, $0.close) }.min() ?? 0
        let candleMax = candles.map { max($0.high, $0.open, $0.close) }.max() ?? 1
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
}

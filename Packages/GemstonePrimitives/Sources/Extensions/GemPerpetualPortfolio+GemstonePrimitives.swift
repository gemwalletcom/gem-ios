// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualPortfolio {
    public func map() -> PerpetualPortfolioChartData {
        PerpetualPortfolioChartData(
            day: day?.map(),
            week: week?.map(),
            month: month?.map(),
            allTime: allTime?.map()
        )
    }
}

extension GemPerpetualPortfolioTimeframeData {
    public func map() -> PerpetualTimeframeChartData {
        PerpetualTimeframeChartData(
            accountValueHistory: accountValueHistory.map { $0.map() },
            pnlHistory: pnlHistory.map { $0.map() },
            volume: volume
        )
    }
}

extension GemPerpetualPortfolioDataPoint {
    public func map() -> ChartDateValue {
        ChartDateValue(
            date: Date(timeIntervalSince1970: TimeInterval(date)),
            value: value
        )
    }
}

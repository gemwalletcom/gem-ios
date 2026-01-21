// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualTimeframeChartData {
    static func mock(
        accountValueHistory: [ChartDateValue] = ChartDateValue.mockHistory(values: [100, 105, 102, 108, 110]),
        pnlHistory: [ChartDateValue] = ChartDateValue.mockHistory(values: [0, 5, 2, 8, 10]),
        volume: Double = 50000
    ) -> PerpetualTimeframeChartData {
        PerpetualTimeframeChartData(
            accountValueHistory: accountValueHistory,
            pnlHistory: pnlHistory,
            volume: volume
        )
    }
}

public extension PerpetualPortfolioChartData {
    static func mock(
        day: PerpetualTimeframeChartData? = .mock(),
        week: PerpetualTimeframeChartData? = .mock(),
        month: PerpetualTimeframeChartData? = .mock(),
        allTime: PerpetualTimeframeChartData? = .mock()
    ) -> PerpetualPortfolioChartData {
        PerpetualPortfolioChartData(
            day: day,
            week: week,
            month: month,
            allTime: allTime
        )
    }

    static func mockEmpty() -> PerpetualPortfolioChartData {
        PerpetualPortfolioChartData(
            day: nil,
            week: nil,
            month: nil,
            allTime: nil
        )
    }
}

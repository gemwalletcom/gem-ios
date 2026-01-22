// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPortfolioTimeframeData {
    static func mock(
        accountValueHistory: [ChartDateValue] = ChartDateValue.mockHistory(values: [100, 105, 102, 108, 110]),
        pnlHistory: [ChartDateValue] = ChartDateValue.mockHistory(values: [0, 5, 2, 8, 10]),
        volume: Double = 50000
    ) -> PerpetualPortfolioTimeframeData {
        PerpetualPortfolioTimeframeData(
            accountValueHistory: accountValueHistory,
            pnlHistory: pnlHistory,
            volume: volume
        )
    }
}

public extension PerpetualPortfolio {
    static func mock(
        day: PerpetualPortfolioTimeframeData? = .mock(),
        week: PerpetualPortfolioTimeframeData? = .mock(),
        month: PerpetualPortfolioTimeframeData? = .mock(),
        allTime: PerpetualPortfolioTimeframeData? = .mock(),
        accountSummary: PerpetualAccountSummary? = nil
    ) -> PerpetualPortfolio {
        PerpetualPortfolio(
            day: day,
            week: week,
            month: month,
            allTime: allTime,
            accountSummary: accountSummary
        )
    }

    static func mockEmpty() -> PerpetualPortfolio {
        PerpetualPortfolio(
            day: nil,
            week: nil,
            month: nil,
            allTime: nil,
            accountSummary: nil
        )
    }
}

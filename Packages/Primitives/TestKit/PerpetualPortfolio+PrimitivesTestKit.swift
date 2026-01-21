// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension PerpetualPortfolioDataPoint {
    static func mock(
        date: Date = Date(),
        value: Double = 100.0
    ) -> PerpetualPortfolioDataPoint {
        PerpetualPortfolioDataPoint(date: date, value: value)
    }

    static func mockHistory(
        startDate: Date = Date().addingTimeInterval(-86400),
        values: [Double] = [100, 105, 102, 108, 110]
    ) -> [PerpetualPortfolioDataPoint] {
        let interval = 86400.0 / Double(values.count)
        return values.enumerated().map { index, value in
            PerpetualPortfolioDataPoint(
                date: startDate.addingTimeInterval(Double(index) * interval),
                value: value
            )
        }
    }
}

public extension PerpetualPortfolioTimeframeData {
    static func mock(
        accountValueHistory: [PerpetualPortfolioDataPoint] = PerpetualPortfolioDataPoint.mockHistory(values: [100, 105, 102, 108, 110]),
        pnlHistory: [PerpetualPortfolioDataPoint] = PerpetualPortfolioDataPoint.mockHistory(values: [0, 5, 2, 8, 10]),
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
        allTime: PerpetualPortfolioTimeframeData? = .mock()
    ) -> PerpetualPortfolio {
        PerpetualPortfolio(
            day: day,
            week: week,
            month: month,
            allTime: allTime
        )
    }

    static func mockEmpty() -> PerpetualPortfolio {
        PerpetualPortfolio(
            day: nil,
            week: nil,
            month: nil,
            allTime: nil
        )
    }
}

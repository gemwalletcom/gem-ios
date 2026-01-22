// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualPortfolio {
    public func map() -> PerpetualPortfolio {
        PerpetualPortfolio(
            day: day?.map(),
            week: week?.map(),
            month: month?.map(),
            allTime: allTime?.map(),
            accountSummary: accountSummary?.map()
        )
    }
}

extension GemPerpetualPortfolioTimeframeData {
    public func map() -> PerpetualPortfolioTimeframeData {
        PerpetualPortfolioTimeframeData(
            accountValueHistory: accountValueHistory.map { $0.map() },
            pnlHistory: pnlHistory.map { $0.map() },
            volume: volume
        )
    }
}

extension GemPerpetualPortfolioDataPoint {
    public func map() -> PerpetualPortfolioDataPoint {
        PerpetualPortfolioDataPoint(
            date: Date(timeIntervalSince1970: TimeInterval(date)),
            value: value
        )
    }
}

extension GemPerpetualAccountSummary {
    public func map() -> PerpetualAccountSummary {
        PerpetualAccountSummary(
            accountValue: accountValue,
            accountLeverage: accountLeverage,
            marginUsage: marginUsage,
            unrealizedPnl: unrealizedPnl
        )
    }
}

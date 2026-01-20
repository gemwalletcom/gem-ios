// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PerpetualPortfolioChartData: Sendable, Equatable {
    public let day: PerpetualTimeframeChartData?
    public let week: PerpetualTimeframeChartData?
    public let month: PerpetualTimeframeChartData?
    public let allTime: PerpetualTimeframeChartData?

    public init(
        day: PerpetualTimeframeChartData?,
        week: PerpetualTimeframeChartData?,
        month: PerpetualTimeframeChartData?,
        allTime: PerpetualTimeframeChartData?
    ) {
        self.day = day
        self.week = week
        self.month = month
        self.allTime = allTime
    }

    public var availablePeriods: [ChartPeriod] {
        [(day, ChartPeriod.day), (week, .week), (month, .month), (allTime, .all)].compactMap { $0.0 != nil ? $0.1 : nil }
    }

    public func timeframeData(for period: ChartPeriod) -> PerpetualTimeframeChartData? {
        switch period {
        case .hour, .day: day
        case .week: week
        case .month: month
        case .year, .all: allTime
        }
    }
}

public struct PerpetualTimeframeChartData: Sendable, Equatable {
    public let accountValueHistory: [ChartDateValue]
    public let pnlHistory: [ChartDateValue]
    public let volume: Double

    public init(
        accountValueHistory: [ChartDateValue],
        pnlHistory: [ChartDateValue],
        volume: Double
    ) {
        self.accountValueHistory = accountValueHistory
        self.pnlHistory = pnlHistory
        self.volume = volume
    }
}

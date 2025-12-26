// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters

public struct ChartDateFormatter {
    private static let relativeDateFormatter = RelativeDateFormatter()

    private let period: ChartPeriod
    private let date: Date

    public init(
        period: ChartPeriod,
        date: Date
    ) {
        self.period = period
        self.date = date
    }

    private var includeTime: Bool {
        switch period {
        case .hour, .day, .week, .month:
            return true
        case .year, .all:
            return false
        }
    }

    public var dateText: String {
        Self.relativeDateFormatter.string(from: date, includeTime: includeTime)
    }
}

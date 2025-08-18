// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension ChartPeriod: Identifiable {
    public var id: String { rawValue }
}

extension ChartPeriod {
    public init(id: String) throws {
        if let period = ChartPeriod(rawValue: id) {
            self = period
        } else {
            throw AnyError("invalid chart period: \(id)")
        }
    }
    
    public var duration: Int {
        switch self {
        case .hour:
            return 60 * 60 // 1 hour
        case .day:
            return 24 * 60 * 60 // 24 hours
        case .week:
            return 7 * 24 * 60 * 60 // 7 days
        case .month:
            return 30 * 24 * 60 * 60 // 30 days
        case .year:
            return 365 * 24 * 60 * 60 // 365 days
        case .all:
            return 365 * 5 * 24 * 60 * 60 // 5 years
        }
    }
}
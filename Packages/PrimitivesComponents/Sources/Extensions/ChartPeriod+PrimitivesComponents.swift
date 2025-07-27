// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

extension ChartPeriod {
    public var title: String {
        switch self {
        case .hour: return Localized.Charts.hour
        case .day: return Localized.Charts.day
        case .week: return Localized.Charts.week
        case .month: return Localized.Charts.month
        case .year: return Localized.Charts.year
        case .all: return Localized.Charts.all
        }
    }
}

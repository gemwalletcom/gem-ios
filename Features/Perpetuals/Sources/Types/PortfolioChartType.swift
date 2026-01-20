// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PortfolioChartType: String, CaseIterable, Identifiable {
    case value
    case pnl

    public var id: String { rawValue }
}

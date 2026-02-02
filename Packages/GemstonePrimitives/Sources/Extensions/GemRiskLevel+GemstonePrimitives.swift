// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

extension GemRiskLevel {
    public var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    public var dotCount: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        }
    }
}

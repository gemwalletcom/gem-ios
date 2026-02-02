// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Gemstone
import Style

extension GemRiskLevel {
    public var color: Color {
        switch self {
        case .low: Colors.green
        case .medium: Colors.orange
        case .high: Colors.red
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PerpetualMarginType {
    public var displayText: String {
        switch self {
        case .cross: "Cross"
        case .isolated: "Isolated"
        }
    }
}
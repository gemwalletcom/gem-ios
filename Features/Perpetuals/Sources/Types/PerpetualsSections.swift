// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PerpetualsSections: Hashable, Sendable {
    public let pinned: [PerpetualData]
    public let markets: [PerpetualData]
    
    public init(pinned: [PerpetualData], markets: [PerpetualData]) {
        self.pinned = pinned
        self.markets = markets
    }
}

public extension PerpetualsSections {
    static func from(_ perpetuals: [PerpetualData]) -> PerpetualsSections {
        PerpetualsSections(
            pinned: perpetuals.filter { $0.metadata.isPinned },
            markets: perpetuals
        )
    }
}
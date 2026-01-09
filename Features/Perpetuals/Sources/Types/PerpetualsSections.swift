// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PerpetualsSections: Hashable, Sendable {
    public let pinned: [PerpetualData]
    public let markets: [PerpetualData]
}

public extension PerpetualsSections {
    static func from(_ perpetuals: [PerpetualData]) -> PerpetualsSections {
        let (pinned, markets) = perpetuals.reduce(into: ([PerpetualData](), [PerpetualData]())) {
            $1.metadata.isPinned ? $0.0.append($1) : $0.1.append($1)
        }
        return PerpetualsSections(pinned: pinned, markets: markets)
    }
}
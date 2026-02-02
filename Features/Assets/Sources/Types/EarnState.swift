// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

public struct EarnState: Sendable {
    public var hasOpportunity: Bool
    public var position: GemYieldPosition?
    public var isPositionLoaded: Bool

    public init(
        hasOpportunity: Bool = false,
        position: GemYieldPosition? = nil,
        isPositionLoaded: Bool = false
    ) {
        self.hasOpportunity = hasOpportunity
        self.position = position
        self.isPositionLoaded = isPositionLoaded
    }

    public static let initial = EarnState()
}

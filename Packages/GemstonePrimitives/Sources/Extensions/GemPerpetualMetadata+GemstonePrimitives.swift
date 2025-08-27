// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemPerpetualMetadata {
    public func map() -> PerpetualMetadata {
        PerpetualMetadata(isPinned: isPinned)
    }
}
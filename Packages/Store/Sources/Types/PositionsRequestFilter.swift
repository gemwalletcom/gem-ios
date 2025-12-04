// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum PositionsRequestFilter: Hashable, Sendable {
    case perpetualId(String)
    case assetId(AssetId)
}

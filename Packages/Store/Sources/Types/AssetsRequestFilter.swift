// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AssetsRequestFilter {
    case search(String)
    case hasBalance
    case hasFiatValue
    case buyable // available to buy
    case swappable
    case stakeable
    case enabled
    case hidden
    case chains([String])
    case includePinned(Bool)

    // special case
    case includeNewAssets
}

extension AssetsRequestFilter: Equatable {}

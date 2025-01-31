// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AssetsRequestFilter {
    case search(String)
    case hasBalance
    case buyable // available to buy
    case swappable
    case stakeable
    case enabled
    case hidden
    case chains([String])
    case chainsOrAssets([String], [String])

    // special case
    case includeNewAssets
    /// AssetData with empty properties
    case priceAlerts
}

extension AssetsRequestFilter: Equatable {}
extension AssetsRequestFilter: Sendable {}

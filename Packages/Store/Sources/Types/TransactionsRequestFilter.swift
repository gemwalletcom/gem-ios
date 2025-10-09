// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransactionsRequestFilter {
    case chains([String])
    case types([String])
    case assetRankGreaterThan(Int)
}

extension TransactionsRequestFilter: Equatable {}
extension TransactionsRequestFilter: Sendable {}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransactionsRequestFilter {
    case chains([String])
}

extension TransactionsRequestFilter: Equatable {}
extension TransactionsRequestFilter: Sendable {}

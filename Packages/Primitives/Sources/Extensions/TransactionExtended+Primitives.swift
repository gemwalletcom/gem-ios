// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension TransactionExtended: Equatable {
    public static func == (lhs: TransactionExtended, rhs: TransactionExtended) -> Bool {
        lhs.transaction == rhs.transaction
    }
}
extension TransactionExtended: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transaction.id)
        hasher.combine(transaction.state.rawValue)
        hasher.combine(transaction.createdAt)
    }
}

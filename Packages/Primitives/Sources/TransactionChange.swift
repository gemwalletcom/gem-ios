// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransactionChanges {
    public let state: TransactionState
    public let changes: [TransactionChange]
    
    public init(state: TransactionState, changes: [TransactionChange] = []) {
        self.state = state
        self.changes = changes
    }
}

public enum TransactionChange {
    case networkFee(BigInt)
    case hashChange(old: String, new: String)
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransactionChanges: Sendable {
    public let state: TransactionState
    public let changes: [TransactionChange]
    
    public init(state: TransactionState, changes: [TransactionChange] = []) {
        self.state = state
        self.changes = changes
    }
}

public enum TransactionChange: Sendable {
    case networkFee(BigInt)
    case blockNumber(Int)
    case createdAt(Date)
    case hashChange(old: String, new: String)
    case metadata(TransactionMetadata)
}

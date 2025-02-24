// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension TransactionMetadata {
    var swap: TransactionSwapMetadata? {
        switch self {
        case .null: .none
        case let .swap(transactionSwapMetadata): transactionSwapMetadata
        }
    }
}

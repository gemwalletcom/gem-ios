// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemTransactionMetadata {
    public func map() -> TransactionMetadata {
        switch self {
        case .perpetual(let perpetualMetadata):
            return .perpetual(TransactionPerpetualMetadata(
                pnl: perpetualMetadata.pnl,
                price: perpetualMetadata.price
            ))
        }
    }
}
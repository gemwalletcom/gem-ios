// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.TransactionMetadata {
    public func map() -> Primitives.TransactionMetadata {
        switch self {
        case .perpetual(let perpetualMetadata):
            return .perpetual(Primitives.TransactionPerpetualMetadata(
                pnl: perpetualMetadata.pnl,
                price: perpetualMetadata.price,
                direction: perpetualMetadata.direction.map(),
                provider: perpetualMetadata.provider?.map()
            ))
        }
    }
}

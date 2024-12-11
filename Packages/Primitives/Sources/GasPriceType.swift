// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum GasPriceType: Equatable, Sendable {
    case regular(gasPrice: BigInt)
    case eip1559(gasPrice: BigInt, priorityFee: BigInt)
    
    public var gasPrice: BigInt {
        switch self {
        case .regular(let gasPrice):
            return gasPrice
        case .eip1559(let gasPrice, _):
            return gasPrice
        }
    }
    
    public var priorityFee: BigInt {
        switch self {
        case .regular: .zero
        case .eip1559(_, let priorityFee): priorityFee
        }
    }
    
    public var totalFee: BigInt {
        gasPrice + priorityFee
    }
}

extension GasPriceType: Hashable {}

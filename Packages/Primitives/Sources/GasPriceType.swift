// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum GasPriceType: Equatable {
    case regular(gasPrice: BigInt)
    case eip1559(gasPrice: BigInt, minerFee: BigInt)
    
    public var gasPrice: BigInt {
        switch self {
        case .regular(let gasPrice):
            return gasPrice
        case .eip1559(let gasPrice, _):
            return gasPrice
        }
    }
}

extension GasPriceType: Hashable {}

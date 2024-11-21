// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum GasPriceType: Equatable, Sendable {
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
    
    public var minerFee: BigInt {
        switch self {
        case .regular: .zero
        case .eip1559(_, let minerFee): minerFee
        }
    }
}

extension GasPriceType: Hashable {}

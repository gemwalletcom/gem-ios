// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemGasPriceType {
    public func map() throws -> GasPriceType {
        switch self {
        case .regular(let gasPrice):
            return GasPriceType.regular(gasPrice: try BigInt.from(string: gasPrice))
        case .eip1559(let gasPrice, let priorityFee):
            return GasPriceType.eip1559(gasPrice: try BigInt.from(string: gasPrice), priorityFee: try BigInt.from(string: priorityFee))
        case .solana(let gasPrice, let priorityFee, let unitPrice):
            return GasPriceType.solana(gasPrice: try BigInt.from(string: gasPrice), priorityFee: try BigInt.from(string: priorityFee), unitPrice: try BigInt.from(string: unitPrice))
        }
    }
}

extension GasPriceType {
    public func map() -> GemGasPriceType {
        switch self {
        case .regular(let gasPrice):
            return .regular(gasPrice: gasPrice.description)
        case .eip1559(let gasPrice, let priorityFee):
            return .eip1559(gasPrice: gasPrice.description, priorityFee: priorityFee.description)
        case .solana(let gasPrice, let priorityFee, let unitPrice):
            return .solana(gasPrice: gasPrice.description, priorityFee: priorityFee.description, unitPrice: unitPrice.description)
        }
    }
}

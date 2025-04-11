// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import Primitives

public extension SwapQuoteData {
    func gasLimit() throws -> BigInt {
        if let gasLimit = gasLimit {
            return BigInt(stringLiteral: gasLimit)
        }
        throw AnyError("No gas limit")
    }

    func value() -> BigInt {
        BigInt(stringLiteral: value)
    }
}

// FIXME: try Swift Macro and generate this code
public extension Primitives.SwapProvider {
    var asGemstone: Gemstone.SwapProvider {
        switch self {
        case .uniswapV3: .uniswapV3
        case .uniswapV4: .uniswapV4
        case .pancakeSwapV3: .pancakeSwapV3
        case .pancakeSwapAptosV2: .pancakeSwapAptosV2
        case .thorchain: .thorchain
        case .orca: .orca
        case .jupiter: .jupiter
        case .across: .across
        case .oku: .oku
        case .wagmi: .wagmi
        case .cetus: .cetus
        case .stonFiV2: .stonFiV2
        case .mayan: .mayan
        case .reservoir: .reservoir
        }
    }
}

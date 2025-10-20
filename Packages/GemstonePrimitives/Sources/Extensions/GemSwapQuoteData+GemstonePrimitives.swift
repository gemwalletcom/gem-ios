// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapQuoteData
import enum Gemstone.GemSwapQuoteDataType
import Primitives

public extension Gemstone.GemSwapQuoteData {
    func map() throws -> Primitives.SwapQuoteData {
        Primitives.SwapQuoteData(
            to: to,
            dataType: dataType.map(),
            value: value,
            data: data,
            memo: memo,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}

extension Primitives.SwapQuoteData {
    func map() -> Gemstone.GemSwapQuoteData {
        Gemstone.GemSwapQuoteData(
            to: to,
            dataType: dataType.map(),
            value: value,
            data: data,
            memo: memo,
            approval: approval?.map(),
            gasLimit: gasLimit
        )
    }
}


extension Primitives.SwapQuoteDataType {
    func map() -> Gemstone.GemSwapQuoteDataType {
        switch self {
        case .contract: .contract
        case .transfer: .transfer
        }
    }
}

extension Gemstone.GemSwapQuoteDataType {
    func map() -> Primitives.SwapQuoteDataType {
        switch self {
        case .contract: .contract
        case .transfer: .transfer
        }
    }
}

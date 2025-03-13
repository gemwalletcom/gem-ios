// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import BigInt

public struct SwapValueFormatter {
    private let formatter: ValueFormatter

    public init(valueFormatter: ValueFormatter) {
        self.formatter = valueFormatter
    }

    public func format(inputValue: String, decimals: Int) throws -> BigInt {
        let value = try formatter.inputNumber(from: inputValue, decimals: decimals)
        guard value > 0 else {
            throw SwapQuoteInputError.invalidAmount
        }
        return value
    }

    public func format(quoteValue: String, decimals: Int) throws -> String {
        let value = try BigInt.from(string: quoteValue)
        return format(value: value, decimals: decimals)
    }

    public func format(value: BigInt, decimals: Int) -> String {
        formatter.string(value, decimals: decimals)
    }
}

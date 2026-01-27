// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

public extension BigInt {
    static func from(_ string: String, decimals: Int) throws -> BigInt {
        try BigNumberFormatter.standard.number(from: string, decimals: decimals)
    }

    func ceilToPrecision(decimals: Int, precision: Int) -> BigInt {
        guard decimals > precision, self > 0 else { return self }
        let factor = BigInt(10).power(decimals - precision)
        return ((self - 1) / factor + 1) * factor
    }
}

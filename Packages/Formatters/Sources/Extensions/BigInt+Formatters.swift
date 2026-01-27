// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

public extension BigInt {
    static func from(_ string: String, decimals: Int) throws -> BigInt {
        try BigNumberFormatter.standard.number(from: string, decimals: decimals)
    }
}

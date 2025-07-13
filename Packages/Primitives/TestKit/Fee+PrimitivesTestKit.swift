// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension Fee {
    static func mock(
        fee: BigInt = BigInt(21000),
        gasPriceType: GasPriceType = .regular(gasPrice: BigInt(1000000000)),
        gasLimit: BigInt = BigInt(21000),
        options: FeeOptionMap = [:]
    ) -> Fee {
        Fee(
            fee: fee,
            gasPriceType: gasPriceType,
            gasLimit: gasLimit,
            options: options
        )
    }
}
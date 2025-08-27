// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemTransactionLoadFee {
    public func map() throws -> Fee {
        Fee(
            fee: try BigInt.from(string: fee),
            gasPriceType: try gasPriceType.map(),
            gasLimit: try BigInt.from(string: gasLimit),
            options: try options.map()
        )
    }
}

extension Fee {
    public func map() -> Gemstone.GemTransactionLoadFee {
        return Gemstone.GemTransactionLoadFee(
            fee: fee.description,
            gasPriceType: gasPriceType.map(),
            gasLimit: gasLimit.description,
            options: options.map()
        )
    }
}
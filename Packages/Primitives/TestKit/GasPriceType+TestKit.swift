// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import BigInt

public extension GasPriceType {
    static func mockEip1559() -> GasPriceType {
        .eip1559(gasPrice: BigInt(5000), priorityFee: BigInt(10000))
    }
}

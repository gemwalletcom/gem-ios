// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension TransferAmount {
    static func mock(
        value: BigInt = 100,
        networkFee: BigInt = 1,
        useMaxAmount: Bool = false
    ) -> TransferAmount {
        TransferAmount(
            value: value,
            networkFee: networkFee,
            useMaxAmount: useMaxAmount
        )
    }
}

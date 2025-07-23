// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Validators

public struct FeeAvailabilityGuard {
    public static func ensureAvialble(
        fee: BigInt,
        chain: Chain
    ) throws {
        do {
            try PositiveValueValidator<BigInt>().validate(fee)
        } catch {
            throw TransferAmountCalculatorError.insufficientNetworkFee(chain.asset, required: nil)
        }
    }
}

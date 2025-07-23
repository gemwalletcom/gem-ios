// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
import Primitives
import Validators
import PrimitivesTestKit

@testable import Transfer

struct FeeAvailabilityGuardTests {
    private var expectedError: TransferAmountCalculatorError {
        .insufficientNetworkFee(chain.asset, required: nil)
    }

    @Test
    func alwaysThrowsInsufficientNetworkFee() {
        #expect(throws: expectedError) {
            try FeeAvailabilityGuard.ensureAvialble(
                fee: BigInt(0),
                chain: .solana
            )
        }

        #expect(throws: Never.self) {
            try FeeAvailabilityGuard.ensureAvialble(
                fee: BigInt(123_456),
                chain: .solana
            )
        }
    }
}

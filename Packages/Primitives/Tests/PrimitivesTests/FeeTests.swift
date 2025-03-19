// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
@testable import Primitives

final class FeeTests {
    @Test
    func testTotalFee() {
        let fee = Fee(fee: BigInt(1), gasPriceType: .regular(gasPrice: BigInt(1)), gasLimit: .zero)
        #expect(fee.totalFee == BigInt(1))
    }

    @Test
    func testTotalFeeWithTokenCreation() {
        let fee = Fee(
            fee: BigInt(1),
            gasPriceType: .regular(gasPrice: BigInt(1)),
            gasLimit: .zero,
            options: [.tokenAccountCreation: BigInt(10)]
        )
        #expect(fee.totalFee == BigInt(11))
    }
}

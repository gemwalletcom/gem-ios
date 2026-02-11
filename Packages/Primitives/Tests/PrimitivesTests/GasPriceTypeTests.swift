// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import BigInt
@testable import Primitives

struct GasPriceTypeTests {
    @Test
    func totalFee() {
        #expect(GasPriceType.regular(gasPrice: BigInt(1000)).totalFee == BigInt(1000))
        #expect(GasPriceType.eip1559(gasPrice: BigInt(1000), priorityFee: BigInt(200)).totalFee == BigInt(1200))
        #expect(GasPriceType.solana(gasPrice: BigInt(5000), priorityFee: BigInt(1000), unitPrice: BigInt(100)).totalFee == BigInt(6000))
    }
}

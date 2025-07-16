// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import struct Gemstone.PaymentWrapper

@testable import GemstonePrimitives

final class PaymentURLDecoderTests {
    @Test
    func testAddress() throws {
        let result = try PaymentURLDecoder.decode("0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326")
        #expect(result == PaymentWrapper(
            address: "0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326",
            amount: .none,
            memo: .none,
            assetId: .none,
            paymentLink: .none
        ))
    }

    @Test
    func testSolana() throws {
        let result1 = try PaymentURLDecoder.decode("HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5")
        #expect(result1 == PaymentWrapper(
            address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5",
            amount: .none,
            memo: .none,
            assetId: .none,
            paymentLink: .none
        ))

        let result2 = try PaymentURLDecoder.decode("solana:HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5?amount=0.266232")
        #expect(result2 == PaymentWrapper(
            address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5",
            amount: "0.266232",
            memo: .none,
            assetId: "solana",
            paymentLink: .none
        ))
    }
}

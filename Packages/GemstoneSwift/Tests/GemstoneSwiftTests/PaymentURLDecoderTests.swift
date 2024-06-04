// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Gemstone
@testable import GemstoneSwift

final class PaymentURLDecoderTests: XCTestCase {

    func testAddress() {
        XCTAssertEqual(
            try! PaymentURLDecoder.decode("0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326"),
            PaymentWrapper(address: "0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326", amount: .none, memo: .none, chain: .none)
        )
    }
    
    func testSolana() {
        XCTAssertEqual(
            try! PaymentURLDecoder.decode("HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5"),
            PaymentWrapper(address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5", amount: .none, memo: .none, chain: .none)
        )
        XCTAssertEqual(
            try! PaymentURLDecoder.decode("solana:HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5?amount=0.266232"),
            PaymentWrapper(address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5", amount: "0.266232", memo: .none, chain: .none)
        )
    }
}

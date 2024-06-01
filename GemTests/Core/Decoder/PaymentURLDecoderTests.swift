// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Gem

final class PaymentURLDecoderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testAddress() {
        XCTAssertEqual(
            try! PaymentURLDecoder().decode(""),
            Payment(address: "", amount: .none, memo: .none)
        )
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326"),
            Payment(address: "0x1f9090aaE28b8a3dCeaDf281B0F12828e676c326", amount: .none, memo: .none)
        )
    }
    
    func testSolana() {
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5"),
            Payment(address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5", amount: .none, memo: .none)
        )
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("solana:HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5?amount=0.266232"),
            Payment(address: "HA4hQMs22nCuRN7iLDBsBkboz2SnLM1WkNtzLo6xEDY5", amount: "0.266232", memo: .none)
        )
    }
    
    func testBIP21() {
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("bitcoin:bc1pn6pua8a566z7t822kphpd2el45ntm23354c3krfmpe3nnn33lkcskuxrdl?amount=0.00001"),
            Payment(address: "bc1pn6pua8a566z7t822kphpd2el45ntm23354c3krfmpe3nnn33lkcskuxrdl", amount: "0.00001", memo: .none)
        )
        
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("ethereum:0xA20d8935d61812b7b052E08f0768cFD6D81cB088?amount=0.01233&memo=test"),
            Payment(address: "0xA20d8935d61812b7b052E08f0768cFD6D81cB088", amount: "0.01233", memo: "test")
        )
        
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("solana:3u3ta6yXYgpheLGc2GVF3QkLHAUwBrvX71Eg8XXjJHGw?amount=0.42301"),
            Payment(address: "3u3ta6yXYgpheLGc2GVF3QkLHAUwBrvX71Eg8XXjJHGw", amount: "0.42301", memo: .none)
        )
        XCTAssertEqual(
            try! PaymentURLDecoder().decode("ton:EQAzoUpalAaXnVm5MoiYWRZguLFzY0KxFjLv3MkRq5BXzyiQ?amount=0.00001"),
            Payment(address: "EQAzoUpalAaXnVm5MoiYWRZguLFzY0KxFjLv3MkRq5BXzyiQ", amount: "0.00001", memo: .none)
        )
    }
}

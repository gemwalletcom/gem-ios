// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
import BigInt

final class FeeTests: XCTestCase {

    func testTotalFee() {
        let fee = Fee(fee: BigInt(1), gasPriceType: .regular(gasPrice: BigInt(1)), gasLimit: .zero)
        
        XCTAssertEqual(fee.totalFee, BigInt(1))
    }
    
    func testTotalFeeWithTokenCreation() {
        let fee = Fee(fee: BigInt(1), gasPriceType: .regular(gasPrice: BigInt(1)), gasLimit: .zero, options: [.tokenAccountCreation: BigInt(10)]);
        
        XCTAssertEqual(fee.totalFee, BigInt(11))
    }
}

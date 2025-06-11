// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit

@testable import Validators

struct AddressTextValidatorTests {
    let validETH = "0xb8c77482e45f1f44de1745f52c74426c631bdd52"
    let validBTC = "bc1qhgxl7yjhaazdhrfh0tzge572wkyp43h7t64fal"

    @Test
    func testValidatesCorrectAddress() throws {
        let eth = AddressTextValidator(asset: .mockBNB())
        try eth.validate(validETH)

        let btc = AddressTextValidator(asset: .mock())
        try btc.validate(validBTC)
    }

    @Test
    func testThrowsOnInvalidAddress() {
        let validator = AddressTextValidator(asset: .mock())

        #expect(throws: TransferError.invalidAddress(asset: .mock())) {
            try validator.validate("not-an-address")
        }
    }
}

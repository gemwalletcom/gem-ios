// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import PrimitivesComponents

struct AddressValidatorTests {
    let validETH = "0xb8c77482e45f1f44de1745f52c74426c631bdd52"
    let validBTC = "bc1qhgxl7yjhaazdhrfh0tzge572wkyp43h7t64fal"

    @Test
    func validatesCorrectAddress() throws {
        let validatorEth = AddressValidator(asset: .mockBNB())
        try validatorEth.validate(validETH)

        let validatorBTC = AddressValidator(asset: .mock())
        try validatorBTC.validate(validBTC)
    }

    @Test
    func throwsOnInvalidAddress() {
        let validator = AddressValidator(asset: .mock())

        #expect(throws: TransferError.invalidAddress(asset: .mock())) {
            try validator.validate("not-an-address")
        }
    }
}

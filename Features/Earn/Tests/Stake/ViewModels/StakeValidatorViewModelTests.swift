// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Earn
import PrimitivesTestKit

struct StakeValidatorViewModelTests {

    @Test func testAprText() async throws {
        let model = StakeValidatorViewModel(validator: .mock(apr: 2.15))

        #expect(model.aprText == "APR 2.15%")
    }
}

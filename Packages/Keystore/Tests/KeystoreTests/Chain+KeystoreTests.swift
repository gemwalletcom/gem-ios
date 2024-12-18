// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

final class Chain_KeystoreTests {
    @Test
    func testIsValidAddress() {
        // Expect addresses to be valid
        #expect(Chain.mock(.ethereum).isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))
        #expect(Chain.mock(.ethereum).isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))

        // Expect addresses to be invalid
        #expect(!Chain.mock(.ethereum).isValidAddress("0x123"))
        #expect(!Chain.mock(.ethereum).isValidAddress("0x123"))
    }

    @Test
    func testHasEncodingTypes() {
        for chain in Chain.allCases {
            #expect(chain.defaultKeyEncodingType != nil)
            #expect(!chain.keyEncodingTypes.isEmpty)
        }
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit

final class Chain_KeystoreTests {
    @Test
    func testHasEncodingTypes() {
        for chain in Chain.allCases {
            #expect(!chain.keyEncodingTypes.isEmpty)
        }
    }
}

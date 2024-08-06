// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
import PrimitivesTestKit

final class Chain_KeystoreTests: XCTestCase {

    func testIsValidAddress() {
        XCTAssertTrue(Chain.mock(.ethereum).isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))
        XCTAssertTrue(Chain.mock(.ethereum).isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))
        
        XCTAssertFalse(Chain.mock(.ethereum).isValidAddress("0x123"))
        XCTAssertFalse(Chain.mock(.ethereum).isValidAddress("0x123"))
    }

    func testHasEncodingTypes() {
        for chain in Chain.allCases {
            XCTAssertNotNil(chain.defaultKeyEncodingType)
            XCTAssertFalse(chain.keyEncodingTypes.isEmpty)
        }
    }
}

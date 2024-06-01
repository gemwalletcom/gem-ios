import XCTest
import Primitives

final class Chain_KeystoreTests: XCTestCase {

    func testIsValidAddress() {
        XCTAssertTrue(Chain.ethereum.isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))
        XCTAssertTrue(Chain.ethereum.isValidAddress("0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5"))
        
        XCTAssertFalse(Chain.ethereum.isValidAddress("0x123"))
        XCTAssertFalse(Chain.ethereum.isValidAddress("0x123"))
    }
}

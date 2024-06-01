import XCTest
import BigInt
import Primitives

class BigIntCodableTests: XCTestCase {

    func testDecode() {
        XCTAssertEqual(BigIntable(420), try JSONDecoder().decode(BigIntable.self, from: Data("\"420\"".utf8)))
        XCTAssertEqual(BigIntable(420), try JSONDecoder().decode(BigIntable.self, from: Data("420".utf8)))
    }

    func testEncode() {
        XCTAssertEqual(Data("\"69\"".utf8), try JSONEncoder().encode(BigIntable(69).self))
        XCTAssertEqual(Data("\"69\"".utf8), try JSONEncoder().encode(BigIntable(69).self))
    }
}

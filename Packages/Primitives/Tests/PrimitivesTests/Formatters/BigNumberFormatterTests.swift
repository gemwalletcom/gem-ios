import XCTest
import Primitives
import BigInt

final class BigNumberFormatterTests: XCTestCase {
    
    let formatter = BigNumberFormatter.standard
    let formatterRU_UA = BigNumberFormatter(locale: Locale(identifier: "ru_UA"))
    
    func testFromString() {
        XCTAssertEqual(try! formatter.number(from: "0.00012317", decimals: 8), 12317)
    }
    
    func testFromNumber() {
        XCTAssertEqual(formatter.number(from: 100_000, decimals: 7), 1_000_000_000_000)
        XCTAssertEqual(formatter.number(from: 10, decimals: 0), 10)
    }
    
    func testFromNumberEULocalization() {
        XCTAssertEqual(try! formatterRU_UA.number(from: "0,12317", decimals: 8), 12317000)
    }
    
    func testFromBigInt() {
        XCTAssertEqual(formatter.string(from: BigInt(10000), decimals: 2), "100")
    }
}

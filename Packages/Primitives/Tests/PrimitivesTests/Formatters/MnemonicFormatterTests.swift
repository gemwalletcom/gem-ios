import XCTest
import Primitives

final class MnemonicFormatterTests: XCTestCase {

    let wordsArray = ["test", "test2"]
    let wordsString = "test test2"
    
    func testFromArray() {
        XCTAssertEqual(MnemonicFormatter.fromArray(words:wordsArray), wordsString)
    }
    
    func testToArray() {
        XCTAssertEqual(MnemonicFormatter.toArray(string: wordsString), wordsArray)
        XCTAssertEqual(MnemonicFormatter.toArray(string: "test\n"), ["test"])
    }
}

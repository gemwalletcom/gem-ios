import Testing
import BigInt
import Primitives
import Foundation

class BigIntCodableTests {
    @Test
    func testDecode() throws {
        #expect(try JSONDecoder().decode(BigIntable.self, from: Data("\"420\"".utf8)) == BigIntable(420))
        #expect(try JSONDecoder().decode(BigIntable.self, from: Data("420".utf8)) == BigIntable(420))
    }

    @Test
    func testEncode() throws {
        #expect(try JSONEncoder().encode(BigIntable(69)) == Data("\"69\"".utf8))
        #expect(try JSONEncoder().encode(BigIntable(69)) == Data("\"69\"".utf8))
    }
}

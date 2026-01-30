import Foundation
import Testing
@testable import Primitives

struct DataPrimitivesTests {

    @Test
    func hex() {
        #expect(Data([0x0A, 0x1F, 0xFF]).hex == "0a1fff")
    }

    @Test
    func fromHex() throws {
        let data = try Data.from(hex: "0a1fff")
        #expect(data == Data([0x0A, 0x1F, 0xFF]))
    }

    @Test
    func fromHexWithPrefix() throws {
        let data = try Data.from(hex: "0x0a1fff")
        #expect(data == Data([0x0A, 0x1F, 0xFF]))
    }

    @Test
    func fromHexInvalid() {
        #expect(throws: Error.self) {
            try Data.from(hex: "invalid")
        }
    }

    @Test
    func zeroize() {
        var data = Data([0xFF, 0xAB, 0xCD])
        data.zeroize()
        #expect(data.allSatisfy { $0 == 0 })
    }
}

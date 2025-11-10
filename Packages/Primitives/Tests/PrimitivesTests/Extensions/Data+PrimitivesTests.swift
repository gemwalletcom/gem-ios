import Foundation
import Testing
@testable import Primitives

struct DataPrimitivesTests {

    @Test
    func hex() {
        #expect(Data([0x0A, 0x1F, 0xFF]).hex == "0a1fff")
    }

    @Test
    func zeroize() {
        var data = Data([0xFF, 0xAB, 0xCD])
        data.zeroize()
        #expect(data.allSatisfy { $0 == 0 })
    }
}

// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import Blockchain

final class EthereumServiceTests {
    @Test
    func testDecodeABIHex() {
        var hex = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000855534420436f696e000000000000000000000000000000000000000000000000"
        var result = EthereumService.decodeABI(hexString: hex)
        #expect(result == "USD Coin")

        hex = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002c48656c6c6f20576f726c64212020202048656c6c6f20576f726c64212020202048656c6c6f20576f726c64210000000000000000000000000000000000000000"
        result = EthereumService.decodeABI(hexString: hex)
        #expect(result == "Hello World!    Hello World!    Hello World!")
    }

    @Test
    func testBatchRequests() throws {
        let calls = [
            EthereumProvider.call(["to": "0x1", "data": "0xdead"]),
            EthereumProvider.call(["to": "0x2", "data": "0xbeaf"])
        ]

        let batch = EthereumProvider.batch(requests: calls)

        guard case .data(let data) = batch.data else {
            fatalError()
        }

        let string = String(data: data, encoding: .utf8)!
        print(string)
//        #expect(string == "[]")
    }
}

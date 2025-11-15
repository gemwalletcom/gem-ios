// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
@testable import Formatters

final class AddressFormatterTests {
    @Test
    func testShort() {
        #expect(AddressFormatter(address: "0x12312321321312", chain: .ethereum).value() == "0x12312...21312")
        #expect(AddressFormatter(address: "0x12312321321312", chain: .aptos).value() == "0x1231...21312")
        #expect(AddressFormatter(address: "GLNvG5Ly4cK512oQeJqnwLftwfoPZ4skyDwZWzxorYQ9", chain: .solana).value() == "GLNvG...orYQ9")
        #expect(AddressFormatter(address: "bc1qx2x5cqhymfcnjtg902ky6u5t5htmt7fvqztdsm028hkrvxcl4t2sjtpd9l", chain: .bitcoin).value() == "bc1qx2...tpd9l")
    }

    @Test
    func testExtra() {
        #expect(AddressFormatter(style: .extra(2), address: "0x1231232221321312", chain: .ethereum).value() == "0x123123...21321312")
        #expect(AddressFormatter(style: .extra(2), address: "0x12313332321321312", chain: .aptos).value() == "0x123133...1321312")
    }

    @Test
    func testFull() {
        #expect(AddressFormatter(style: .full, address: "0x1231232221321312", chain: .ethereum).value() == "0x1231232221321312")
        #expect(AddressFormatter(style: .full, address: "0x12313332321321312", chain: .aptos).value() == "0x12313332321321312")
    }
}

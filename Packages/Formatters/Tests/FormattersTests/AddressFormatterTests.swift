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

    @Test
    func testGrouped4() {
        #expect(AddressFormatter(style: .grouped(length: 4), address: "0x1231232221321312", chain: .ethereum).value() == "0x 1231 2322 2132 1312")
        #expect(AddressFormatter(style: .grouped(length: 4), address: "0x4F955d25C76cee046F991e87AFdF96FeEB1771F5", chain: .solana).value() == "0x 4F95 5d25 C76c ee04 6F99 1e87 AFdF 96Fe EB17 71F5")
        #expect(AddressFormatter(style: .grouped(length: 4), address: "bc1qf6alks7awd5vnjyk2k87hveavtsj929lc5ra8h", chain: .bitcoin).value() == "bc 1qf6 alks 7awd 5vnj yk2k 87hv eavt sj92 9lc5 ra8h")
    }
}

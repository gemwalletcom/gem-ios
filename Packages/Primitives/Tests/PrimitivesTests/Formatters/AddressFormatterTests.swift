// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives

final class AddressFormatterTests: XCTestCase {

    func testShort() {
        XCTAssertEqual(AddressFormatter(address: "0x12312321321312", chain: .ethereum).value(), "0x1231...1312")
        XCTAssertEqual(AddressFormatter(address: "0x12312321321312", chain: .aptos).value(), "0x1231...1312")
        XCTAssertEqual(AddressFormatter(address: "GLNvG5Ly4cK512oQeJqnwLftwfoPZ4skyDwZWzxorYQ9", chain: .solana).value(), "GLNv...rYQ9")
        XCTAssertEqual(AddressFormatter(address: "bc1qx2x5cqhymfcnjtg902ky6u5t5htmt7fvqztdsm028hkrvxcl4t2sjtpd9l", chain: .bitcoin).value(), "bc1qx2...pd9l")
    }
    
    func testExtra() {
        XCTAssertEqual(AddressFormatter(style: .extra(2), address: "0x1231232221321312", chain: .ethereum).value(), "0x123123...321312")
        XCTAssertEqual(AddressFormatter(style: .extra(2),address: "0x12313332321321312", chain: .aptos).value(), "0x123133...321312")
    }
    
    func testFull() {
        XCTAssertEqual(AddressFormatter(style: .full, address: "0x1231232221321312", chain: .ethereum).value(), "0x1231232221321312")
        XCTAssertEqual(AddressFormatter(style: .full,address: "0x12313332321321312", chain: .aptos).value(), "0x12313332321321312")
    }
}

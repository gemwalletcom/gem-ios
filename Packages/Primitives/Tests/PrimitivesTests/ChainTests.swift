// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

struct ChainTests {

    @Test
    func testShortAddress() throws {
        #expect(Chain.ethereum.shortAddress(address: "0x123") == "0x123")
        #expect(Chain.bitcoinCash.shortAddress(address: "bitcoincash:123") == "123")
    }
    
    @Test
    func testFullAddress() throws {
        #expect(Chain.ethereum.fullAddress(address: "0x123") == "0x123")
        #expect(Chain.bitcoinCash.fullAddress(address: "123") == "bitcoincash:123")
        #expect(Chain.bitcoinCash.fullAddress(address: "bitcoincash:123") == "bitcoincash:123")
    }
}

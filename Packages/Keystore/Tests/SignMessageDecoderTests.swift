// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Keystore
import Primitives
import WalletCore

final class SignMessageDecoderTests {

    @Test
    func testEIP191() {
        let data = "test".data(using: .utf8)!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .eip191, data: data)
        )
        #expect(decoder.preview == "test")
    }

    @Test
    func testEIP191HexValue() {
        let data = Data(fromHex: "0x74657374")!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .eip191, data: data)
        )
        #expect(decoder.preview == "test")
    }

    @Test
    func testBase58() {
        let data = "StV1DL6CwTryKyV".data(using: .utf8)!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .base58, data: data)
        )
        #expect(decoder.preview == "hello world")
        #expect(decoder.getResult(from: data) == "3LRFsmWKLfsR7G5PqjytR")
    }
}

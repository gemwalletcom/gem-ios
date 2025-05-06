// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Keystore
import Primitives
import WalletCore
import struct Gemstone.SignMessage

final class SignMessageDecoderTests {

    @Test
    func testEIP191() {
        let data = "test".data(using: .utf8)!
        let decoder = SignMessageDecoderDefault(
            message: SignMessage(signType: .eip191, data: data)
        )
        #expect(decoder.plainPreview == "test")
    }

    @Test
    func testEIP191HexValue() {
        let data = Data(fromHex: "0x74657374")!
        let decoder = SignMessageDecoderDefault(
            message: SignMessage(signType: .eip191, data: data)
        )
        #expect(decoder.plainPreview == "test")
    }

    @Test
    func testBase58() {
        let data = "StV1DL6CwTryKyV".data(using: .utf8)!
        let decoder = SignMessageDecoderDefault(
            message: SignMessage(signType: .base58, data: data)
        )
        #expect(decoder.plainPreview == "hello world")
        #expect(decoder.getResult(from: data) == "3LRFsmWKLfsR7G5PqjytR")
    }
    
    @Test
    func testTextPreview() throws {
        let data = "StV1DL6CwTryKyV".data(using: .utf8)!
        let decoder = SignMessageDecoderDefault(
            message: SignMessage(signType: .base58, data: data)
        )
        #expect(try decoder.preview == .text("hello world"))
    }
}

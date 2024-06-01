// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Keystore
import Primitives
import WalletCore

final class SignMessageDecoderTests: XCTestCase {

    func testEIP191() {
        let data = "test".data(using: .utf8)!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .eip191, data: data)
        )
        
        XCTAssertEqual("test", decoder.preview)
    }
    
    func testEIP191HexValue() {
        let data = Data(fromHex: "0x74657374")!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .eip191, data: data)
        )
        
        XCTAssertEqual("test", decoder.preview)
    }

    func testBase58() {
        let data = "StV1DL6CwTryKyV".data(using: .utf8)!
        let decoder = SignMessageDecoder(
            message: SignMessage(type: .base58, data: data)
        )
        
        XCTAssertEqual("hello world", decoder.preview)
        XCTAssertEqual("3LRFsmWKLfsR7G5PqjytR", decoder.getResult(from: data))
    }
}
